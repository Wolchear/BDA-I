from workflow.lib.utils import get_path

RAW_DIR = get_path(config["data"], 'raw')
RAW_DATA_SUFFIX = f"{config['suffix']['fastq']}.{config['suffix']['compress']}"
REPORT_SUFFIX = config['suffix']['report']
REPORTS_DIR = get_path(config['output'], 'reports') 
FASTQC_PARAMS = config['fastqc_params']

rule fastqc:
    input:
        html = f"{REPORTS_DIR}/{{acc}}_{{paired_id}}_fastqc.html",
        zip  = f"{REPORTS_DIR}/{{acc}}_{{paired_id}}_fastqc.zip"
    output:
        f"{REPORTS_DIR}/{{acc}}_{{paired_id}}.{REPORT_SUFFIX}"
    threads: FASTQC_PARAMS['threads']
    params:
        outdir={REPORTS_DIR}
    shell:
        r"""
        fastqc -t {threads} -o {params.outdir} {input}
        """