from workflow.lib.utils import get_path

PLOT_DIR =  get_path(config["qc"], "mapping")
SRA = config['sra']
QC_SCRIPT = config['mapping_qc_params']['script']

MAPPED_DIR =  get_path(config["output"], "mapped")

rule plot_mapping_rates:
    input:
        expand("logs/hisat2/{acc}.log", acc=SRA)
    output:
        f"{PLOT_DIR}/mapping_rates.png"
    params:
        log_dir="logs/hisat2",
        script=QC_SCRIPT
    shell:
        r"""
        python3 {params.script} \
            -d {params.log_dir} \
            -o {output}
        """

rule get_matrix:
    input:
        expand(f"{MAPPED_DIR}/{{acc}}.sorted.bam", acc=SRA)
    output:
        f"{PLOT_DIR}/samples_matrix.npz"
    shell:
        """
        multiBamSummary bins --bamfiles {input} -o {output}  
        """

rule plot_correlation:
    input:
        rules.get_matrix.output
    output:
        f"{PLOT_DIR}/correlation.png"
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
    shell:
        r"""
        plotPCA  -in {input} -o {output}
        """  