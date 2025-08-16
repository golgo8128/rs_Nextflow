#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to a file
 */

params.greeting = 'greetings.csv'


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

    sayHello.out.view { tmp -> "$tmp" } 

    // convert the greeting to uppercase
    convertToUpper(sayHello.out)


}

