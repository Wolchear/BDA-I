from workflow.lib.utils import get_path

SRA = config['sra']

MAPPED_DIR =  get_path(config["output"], "mapped")
OUT_DIR = config["output"]['base_root']

REF_DIR = get_path(config["data"], 'references')
BED_ANNOT_CONF = config["ref"]['bed_annotation']
REF = config["ref"]

PLOT_DIR =  get_path(config["qc"], "mapping")

QC_SCRIPTS = config['mapping_qc_scripts']

rule quantify_gene_expression:
    input:
        bams=expand("{mapped_dir}/{acc}.sorted.bam", mapped_dir=MAPPED_DIR, acc=SRA),
        gtf= f"{REF_DIR}/{REF['annotation']['file_name']}"
    output:
        counts=f"{OUT_DIR}/all.counts.txt",
        summary=f"{OUT_DIR}/all.counts.txt.summary"
    threads: 6
    shell:
        r"""
        featureCounts -T {threads} \
                      -p \
                      --countReadPairs \
                      -s 0 \
                      -t exon \
                      -g gene_id \
                      -a {input.gtf} \
                      -o {output.counts} \
                      {input.bams}
        """

rule plot_feat_asiggned:
    input:
        rules.quantify_gene_expression.output.summary
    output:
        f"{PLOT_DIR}/assigned_rates.png"
    params:
        script = QC_SCRIPTS['assigned_rates']
    threads: 1
    shell:
        """
        Rscript {params.script} {input} {output}
        """