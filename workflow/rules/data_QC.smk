from workflow.lib.utils import get_path

SRA = config['sra']

RAW_DIR = get_path(config["data"], 'raw')
DATA_SUFFIX = f"{config['suffix']['fastq']}.{config['suffix']['compress']}"

TRIMMED_DIR = get_path(config["data"], 'trimmed')
REPORT_SUFFIX = config['suffix']['report']
RAW_REPORTS_DIR = get_path(config['qc'], 'raw') 
TRIMMED_REPORTS_DIR = get_path(config['qc'], 'trimmed')

FASTQC_PARAMS = config['fastqc_params']

rule fastqc_raw:
    input:
        f"{RAW_DIR}/{{acc}}_{{paired_id}}.{DATA_SUFFIX}"
    output:
        html = f"{RAW_REPORTS_DIR}/{{acc}}_{{paired_id}}_fastqc.html",
        zip  = f"{RAW_REPORTS_DIR}/{{acc}}_{{paired_id}}_fastqc.zip"
    wildcard_constraints:
        paired_id="1|2"
    threads: FASTQC_PARAMS['threads']
    params:
        outdir = RAW_REPORTS_DIR
    shell:
        """
        fastqc -t {threads} -o {params.outdir} {input}
        """

rule fastqc_trimmed:
    input:
        f"{TRIMMED_DIR}/{{acc}}_{{paired_id}}.{DATA_SUFFIX}"
    output:
        html = f"{TRIMMED_REPORTS_DIR}/{{acc}}_{{paired_id}}_fastqc.html",
        zip  = f"{TRIMMED_REPORTS_DIR}/{{acc}}_{{paired_id}}_fastqc.zip"
    wildcard_constraints:
        paired_id="1|2"
    threads: FASTQC_PARAMS['threads']
    params:
        outdir = TRIMMED_REPORTS_DIR
    shell:
        """
        fastqc -t {threads} -o {params.outdir} {input}
        """

rule multiqc_raw:
    input:
        expand(f"{RAW_REPORTS_DIR}/{{acc}}_{{paired_id}}_fastqc.html",
               acc=SRA, paired_id=["1","2"])
    output:
        html = f"{RAW_REPORTS_DIR}/multiqc.{REPORT_SUFFIX}",
        data = directory(f"{RAW_REPORTS_DIR}/multiqc_data")
    threads: 1
    params:
        outdir=RAW_REPORTS_DIR,
        out_name=f"multiqc.{REPORT_SUFFIX}"
    shell:
        r"""
        multiqc {params.outdir} \
          -o {params.outdir} \
          -n {params.out_name} \
          -f
        """

rule multiqc_trimmed:
    input:
        expand(f"{TRIMMED_REPORTS_DIR}/{{acc}}_{{paired_id}}_fastqc.html",
               acc=SRA, paired_id=["1","2"])
    output:
        html = f"{TRIMMED_REPORTS_DIR}/multiqc.{REPORT_SUFFIX}",
        data = directory(f"{TRIMMED_REPORTS_DIR}/multiqc_data")
    threads: 1
    params:
        outdir=TRIMMED_REPORTS_DIR,
        out_name=f"multiqc.{REPORT_SUFFIX}"
    shell:
        r"""
        multiqc {params.outdir} \
          -o {params.outdir} \
          -n {params.out_name} \
          -f
        """