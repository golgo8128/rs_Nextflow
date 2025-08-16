#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to a file
 */

params.greeting = 'greetings.csv'
params.batch = 'test-batch'

/*
 * Collect uppercase greetings into a single output file
 */
process collectGreetings {

    publishDir 'results', mode: 'copy'

    input:
	path input_files
	val batch_name

    output:
        path "COLLECTED-${batch_name}-output.txt"

    script:
    """
    cat ${input_files} > 'COLLECTED-${batch_name}-output.txt'
    """
}


/*
 * Use a text replacement tool to convert the greeting to uppercase
 */

process convertToUpper {

    publishDir 'results', mode: 'copy'

    input:
        path input_file

    output:
        path "UPPER-${input_file}"

    script:
    """
    cat '$input_file' | tr '[a-z]' '[A-Z]' > 'UPPER-${input_file}'
    """
}


process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
	path "${greeting}-output.txt"
	

    script:
    """
    echo '$greeting' > '$greeting-output.txt'
    """
}

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

}

