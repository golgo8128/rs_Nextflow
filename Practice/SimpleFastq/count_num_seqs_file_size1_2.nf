nextflow.enable.dsl=2

params.fastq = "DRR515002_partial1.fastq"  // 入力ファイルを指定

workflow {
    // 入力ファイルをチャネルに変換
    fastq_ch = Channel.fromPath(params.fastq)

    // 並列実行
    size_ch = get_size(fastq_ch)
    count_ch = count_reads(fastq_ch)

    // 結果をまとめて出力
    report(size_ch, count_ch)
}

process get_size {
    input:
       path fastq

    output:
       path "file_size.txt"

    script:
    """
    ls -l \$fastq | awk '{ print \$5 } > file_size.txt'
    """
}

process count_reads {
    input:
       path fastq

    output:
       path "num_seqs.txt"

    script:
    """
    awk 'END { print NR/4 }' \$fastq > num_seqs.txt
    """
}

process report {
    input:
       path file_size
       path num_seqs    

    output:
       path "report.txt"

    script:
    """
    echo "File: ${params.fastq}" > report.txt
    echo "Size (bytes):"        >> report.txt
    cat  ${file_size}           >> report.txt
    echo "Read count:"          >> report.txt
    cat  ${num_seqs}            >> report.txt
    """

}

