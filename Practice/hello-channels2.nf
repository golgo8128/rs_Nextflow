#!/usr/bin/env nextflow 

 

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


    // declare an array of input greetings
    greetings_array = ['Hello','Hi','Hey']

    // create a channel for inputs 

    greeting_ch = Channel.of('Hello', 'Hi', 'Hey').flatten()


    // emit a greeting 

    sayHello(greeting_ch) 

}
 
