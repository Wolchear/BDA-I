from workflow.lib.utils import get_path


RAW_DIR = get_path(config["data"], 'raw')
FASTQ_SUFFIX = config['suffix']['fastq']

rule get_data:
    output:
        fasta_1 = f"{RAW_DIR}/{{acc}}_1.{FASTQ_SUFFIX}",
        fasta_2 = f"{RAW_DIR}/{{acc}}_2.{FASTQ_SUFFIX}"
    threads: 2
    params:
        acc="{acc}",
        outdir=RAW_DIR
    log:
        "logs/{acc}/fasterq_dump/{acc}.log"
    shell:
        r"""
        echo "Downloading files for: {wildcards.acc}" >&2

        fasterq-dump {params.acc} \
         -O {params.outdir} \
        --split-files \
        --threads {threads} \
        2> {log}

        """