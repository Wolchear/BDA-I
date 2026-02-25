from workflow.lib.utils import get_path

PLOT_DIR =  get_path(config["qc"], "mapping")
SRA = config['sra']
QC_SCRIPT = config['mapping_qc_params']['script']

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