process kraken2nt_contigs {
    label 'kraken2nt_contigs'
    publishDir "${params.output}/${id}/assembly/taxonomic_deconta", mode: 'copy'

    input:
        tuple val(id), path(contigs)
        path(db_k2nt)
    output:
        tuple val(id), path("${id}_kn2_nt-res.txt")
        tuple val(id), path("${id}_kn2_nt-report.txt")
        tuple val(id), path("${contigs}")
    script:
        """
        kraken2 --db ${db_k2nt} --memory-mapping \
            --threads ${task.cpus} --output ${id}_kn2_nt-res.txt \
            --report-minimizer-data \
            --report ${id}_kn2_nt-report.txt ${contigs}
        """
}

//KrakenTools - retrieval of species of interest
process extract_kraken {
  label 'extract_kraken'
  publishDir "${params.output}/${id}/assembly/taxonomic_deconta", mode: 'copy'

  input:
    tuple val(id), path(contigs)
    tuple val(id), path(kraken_res)
    tuple val(id), path(kraken_report)
    val(taxid)
    path(krakentools)
  output:
    tuple val(id), path("${id}_kraken_extract_contigs_${taxid}.fasta")
  script:
    """
    python ${krakentools} -k ${kraken_res} -r ${kraken_report} \
        -s ${contigs} --include-children -t ${taxid} \
        -o ${id}_kraken_extract_contigs_${taxid}.fasta
    """
}
