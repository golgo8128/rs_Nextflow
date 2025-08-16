#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to a file
 */

params.greeting = 'greetings.csv'

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
    		.view { csv -> "Before splitCsv: $csv" }
		.splitCsv()
		.view { csv -> "After splitCsv: $csv" }
		.map { item -> item[0] }
		.view { csv -> "After map: $csv" }

    // greeting_ch = Channel.of(greetings_array)
    //		.view { greeting_unflatten -> "Before flatten: $greeting_unflatten" }
    //		.flatten()
    //          .view { greeting_flatten -> "After flatten: $greeting_flatten" }

    sayHello(greeting_ch)
    

}

