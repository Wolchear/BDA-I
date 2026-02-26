from workflow.lib.utils import get_path

REF_DIR = get_path(config["data"], 'references')
PLOT_DIR =  get_path(config["qc"], "mapping")
SRA = config['sra']
QC_SCRIPT = config['mapping_qc_params']['script']

MAPPED_DIR =  get_path(config["output"], "mapped")

BED_ANNOT_CONF = config["ref"]['bed_annotation']
PREFIX = f"{PLOT_DIR}/all"

rule plot_mapping_rates:
    input:
        expand("logs/hisat2/{acc}.log", acc=SRA)
    output:
        f"{PLOT_DIR}/mapping_rates.png"
    params:
        log_dir="logs/hisat2",
        script=QC_SCRIPT
    threads:1
    shell:
        r"""
        python3 {params.script} \
            -d {params.log_dir} \
            -o {output}
        """

rule get_matrix:
    input:
        expand("{mapped_dir}/{acc}.sorted.bam", mapped_dir=MAPPED_DIR, acc=SRA)
    output:
        f"{PLOT_DIR}/samples_matrix.npz"
    threads: 1
    shell:
        """
        multiBamSummary bins --bamfiles {input} -o {output}  
        """

rule plot_correlation:
    input:
        rules.get_matrix.output
    output:
        f"{PLOT_DIR}/correlation.png"
    threads: 1
    shell:
        r"""
        plotCorrelation -in {input} \
                        -c spearman \
                        -p heatmap  \
                        -o {output}
        """

rule plot_PCA:
    input:
        rules.get_matrix.output
    output:
        f"{PLOT_DIR}/pca.png"
    threads: 1
    shell:
        r"""
        plotPCA  -in {input} -o {output}
        """

rule plot_gene_body_coverege:
    input:
        bams = expand(f"{MAPPED_DIR}/{{acc}}.sorted.bam", acc=SRA),
        bed = f"{REF_DIR}/{BED_ANNOT_CONF['file_name']}"
    output:
        f"{PREFIX}.geneBodyCoverage.curves.png"
    params:
        prefix=PREFIX
    threads: 1
    shell:
        r"""
        geneBody_coverage.py -i {input.bams} \
                             -r {input.bed} \
                             -f png \
                             -o {params.prefix}
        """

rule plot_inner_distance:
    input:
        bams = expand("{mapped_dir}/{acc}.sorted.bam", mapped_dir=MAPPED_DIR, acc=SRA),
        bed  = f"{REF_DIR}/{BED_ANNOT_CONF['file_name']}"
    output:
        f"{PREFIX}.inner_distance.png"
    params:
        prefix=f"{PREFIX}"
    threads: 1
    shell:
        r"""
        inner_distance.py -i {input.bams} \
                          -r {input.bed} \
                          -o {params.prefix}
        """

rule plot_clipping_profile:
    input:
        bams = expand("{mapped_dir}/{acc}.sorted.bam", mapped_dir=MAPPED_DIR, acc=SRA)
    output:
        f"{PREFIX}.clipping_profile.png"
    params:
        prefix=f"{PREFIX}"
    threads: 1
    shell:
        r"""
        clipping_profile.py -i {input.bams} \
                            -o {params.prefix}
        """

rule plot_annotated_junctions:
    input:
        bams = expand("{mapped_dir}/{acc}.sorted.bam", mapped_dir=MAPPED_DIR, acc=SRA),
        bed  = f"{REF_DIR}/{BED_ANNOT_CONF['file_name']}"
    output:
        f"{PREFIX}.junction_annotation.png"
    params:
        prefix=f"{PREFIX}"
    threads: 1
    shell:
        r"""
        junction_annotation.py -i {input.bams} \
                               -r {input.bed} \
                               -o {params.prefix}
        """