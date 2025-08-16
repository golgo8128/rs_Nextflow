#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to a file
 */

params.greeting = "Hello"

process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path 'output.txt'

    script:
    """
    echo '$greeting' > output.txt
    """
}

workflow {

    // emit a greeting
    // sayHello('Hello World!')
    sayHello(params.greeting)

}

