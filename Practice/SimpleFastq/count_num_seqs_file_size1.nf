nextflow.enable.dsl=2

params.fastq = "sample.fastq"  // 入力ファイルを指定

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
    val(stdout)

    script:
    """
    ls -l \$fastq | awk '{print \$5}'
    """
}

process count_reads {
    input:
    path fastq

    output:
    val(stdout)

    script:
    """
    awk 'END {print NR/4}' \$fastq
    """
}

process report {
    input:
    val(size)
    val(count)

    output:
    path "report.txt"

    script:
    """
    echo "File: ${params.fastq}" > report.txt
    echo "Size (bytes): ${size}" >> report.txt
    echo "Read count: ${count}" >> report.txt
    """
}

