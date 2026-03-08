from workflow.lib.utils import get_path

REF_DIR = get_path(config["data"], 'references')
PLOT_DIR =  get_path(config["qc"], "mapping")
SRA = config['sra']
QC_SCRIPTS = config['mapping_qc_scripts']
MAPPING_RATES_SCRIPT = QC_SCRIPTS['mapping_rates']
AGGR_INNER = QC_SCRIPTS['aggregate_inner']
AGGR_CLIP = QC_SCRIPTS['aggregate_clipping']
AGGR_JUN = QC_SCRIPTS['aggregate_splice']

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
        script=MAPPING_RATES_SCRIPT
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

rule plot_gene_body_coverage:
    input:
        bams = expand(f"{MAPPED_DIR}/{{acc}}.sorted.bam", acc=SRA),
        bed = f"{REF_DIR}/{BED_ANNOT_CONF['file_name']}"
    output:
        f"{PREFIX}.geneBodyCoverage.curves.pdf"
    log:
        f"logs/rseqc/gene_body_coverage/{{acc}}.log"
    params:
        prefix=PREFIX,
        bam_list = lambda wildcards, input: ",".join(input.bams)
    threads: 1
    shell:
        r"""
        geneBody_coverage.py -i {params.bam_list} \
                             -r {input.bed} \
                             -o {params.prefix} \
                             > {log} 2>&1
        """

rule plot_inner_distance:
    input:
        bam = f"{MAPPED_DIR}/{{acc}}.sorted.bam",
        bed  = f"{REF_DIR}/{BED_ANNOT_CONF['file_name']}"
    output:
        plot = f"{PLOT_DIR}/inner_distances/{{acc}}.inner_distance_plot.pdf",
        freq = f"{PLOT_DIR}/inner_distances/{{acc}}.inner_distance_freq.txt",
        meta = f"{PLOT_DIR}/inner_distances/{{acc}}.inner_distance.txt"
    log:
        f"logs/rseqc/inner_distances/{{acc}}.log"
    params:
        prefix=f"{PLOT_DIR}/inner_distances/{{acc}}"
    threads: 1
    shell:
        r"""
        inner_distance.py -i {input.bam} \
                          -r {input.bed} \
                          -o {params.prefix} \
                          > {log} 2>&1
        """
    

rule inner_distance_aggr:
    input:
        expand(f"{PLOT_DIR}/inner_distances/{{acc}}.inner_distance_freq.txt", acc=SRA)
    output:
        f"{PREFIX}.inner_distance_plot.pdf"
    threads: 1
    params:
        script=AGGR_INNER,
        i_dir=f"{PLOT_DIR}/inner_distances",
        prefix=PREFIX
    shell:
        r"""
        Rscript {params.script} {params.i_dir} {params.prefix}
        """

rule plot_clipping_profile:
    input:
        f"{MAPPED_DIR}/{{acc}}.sorted.bam"
    output:
        r1=f"{PLOT_DIR}/clipping_profile/{{acc}}.clipping_profile.R1.pdf",
        r2=f"{PLOT_DIR}/clipping_profile/{{acc}}.clipping_profile.R2.pdf",
        info=f"{PLOT_DIR}/clipping_profile/{{acc}}.clipping_profile.xls"
    log:
        f"logs/rseqc/clipping/{{acc}}.log"
    params:
        prefix=f"{PLOT_DIR}/clipping_profile/{{acc}}"
    threads: 1
    shell:
        r"""
        clipping_profile.py -i {input} \
                            -o {params.prefix} \
                            -s "PE" \
                            > {log} 2>&1
        """

rule plot_clipping_aggr:
    input:
        expand(f"{PLOT_DIR}/clipping_profile/{{acc}}.clipping_profile.xls", acc=SRA)
    output:
        r1 = f"{PREFIX}.clipping_profile.R1.pdf",
        r2 = f"{PREFIX}.clipping_profile.R2.pdf",
    threads: 1
    params:
        script=AGGR_CLIP,
        i_dir=f"{PLOT_DIR}/clipping_profile",
        prefix=PREFIX
    shell:
        r"""
        Rscript {params.script} {params.i_dir} {params.prefix}
        """

rule plot_annotated_junctions:
    input:
        bam = f"{MAPPED_DIR}/{{acc}}.sorted.bam",
        bed  = f"{REF_DIR}/{BED_ANNOT_CONF['file_name']}"
    output:
        events   = f"{PLOT_DIR}/junction_annotation/{{acc}}.splice_events.pdf",
        junction = f"{PLOT_DIR}/junction_annotation/{{acc}}.splice_junction.pdf",
        xls      = f"{PLOT_DIR}/junction_annotation/{{acc}}.junction.xls",
        bed      = f"{PLOT_DIR}/junction_annotation/{{acc}}.junction.bed",
        ibed     = f"{PLOT_DIR}/junction_annotation/{{acc}}.junction.Interact.bed",
        rscript  = f"{PLOT_DIR}/junction_annotation/{{acc}}.junction_plot.r"
    log:
        f"logs/rseqc/junction_annotation/{{acc}}.log"
    params:
        prefix=f"{PLOT_DIR}/junction_annotation/{{acc}}"
    threads: 1
    shell:
        r"""
        junction_annotation.py -i {input.bam} \
                               -r {input.bed} \
                               -o {params.prefix} \
                               > {log} 2>&1
        """

rule junction_annotation_aggr:
    input:
        expand(f"{PLOT_DIR}/junction_annotation/{{acc}}.junction.xls", acc=SRA)
    output:
        events = f"{PREFIX}.splice_events.pdf",
        junctions = f"{PREFIX}.splice_junction.pdf"
    threads: 1
    params:
        script=AGGR_JUN,
        i_dir=f"{PLOT_DIR}/junction_annotation",
        prefix=PREFIX
    shell:
        r"""
        Rscript {params.script} {params.i_dir} {params.prefix}
        """