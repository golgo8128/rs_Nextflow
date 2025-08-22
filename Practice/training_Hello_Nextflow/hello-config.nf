#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to a file
 */

params.greeting = "${System.getenv('RS_PROG_DIR')}/ProgTestData/TextFiles/greetings_single_column1_1.csv"
params.batch = 'test-batch'
params.character = 'turkey'


// Include modules
include { sayHello } from '../modules/sayHello.nf'
include { convertToUpper } from '../modules/convertToUpper.nf'
include { collectGreetings } from '../modules/collectGreetings.nf'

include { cowpy } from '../modules/cowpy.nf' // Start Docker before running this Nextflow script


workflow {

    // emit a greeting

    // greetings_array = ['Hello','Bonjour','Konnichiwa']

    greeting_ch = Channel.fromPath(params.greeting)
    //		.view { csv -> "Before splitCsv: $csv" }
    		.splitCsv()
    //		.view { csv -> "After splitCsv: $csv" }
    		.map { item -> item[0] }
    //		.view { csv -> "After map: $csv" }

    // greeting_ch = Channel.of(greetings_array)
    //		.view { greeting_unflatten -> "Before flatten: $greeting_unflatten" }
    //		.flatten()
    //          .view { greeting_flatten -> "After flatten: $greeting_flatten" }

    sayHello(greeting_ch)

    // sayHello.out.view { tmp -> "$tmp" } 

    // convert the greeting to uppercase
    convertToUpper(sayHello.out)

    // collect all the greetings into one file
    collectGreetings(convertToUpper.out.collect(), params.batch)

    // optional view statements
    convertToUpper.out.view { greeting -> "Before collect: $greeting" }
    convertToUpper.out.collect().view { greeting -> "After collect: $greeting" }

    // emit a message about the size of the batch
    collectGreetings.out.count.view { num_greetings -> "There were $num_greetings greetings in this batch" }

    // generate ASCII art of the greetings with cowpy
    cowpy(collectGreetings.out.outfile, params.character) 

}

