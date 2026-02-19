from workflow.lib.utils import get_path

RAW_DIR = get_path(config["data"], 'raw')
FASTQ_SUFFIX = config['suffix']['fastq']
GZIPPED_SUFFIX = config['suffix']['compress']
FASTERQ_PARAMS = config['fasterq_params']


rule get_data:
    output:
        fasta_1 = f"{RAW_DIR}/{{acc}}_1.{FASTQ_SUFFIX}.{GZIPPED_SUFFIX}",
        fasta_2 = f"{RAW_DIR}/{{acc}}_2.{FASTQ_SUFFIX}.{GZIPPED_SUFFIX}"
    threads: FASTERQ_PARAMS['threads']
    params:
        acc="{acc}",
        outdir=RAW_DIR
    log:
        "logs/fasterq_dump/{acc}.log"
    shell:
        r"""
        echo "Downloading files for: {wildcards.acc}" >&2

        fasterq-dump {params.acc} \
         -O {params.outdir} \
        --split-files \
        --threads {threads} \
        2> {log}

        pigz -p {threads} {out.outdir}/{wildcards.acc}_1.fastq
        pigz -p {threads} {params.outdir}/{wildcards.acc}_2.fastq
        """
