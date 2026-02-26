from workflow.lib.utils import get_path

RAW_DIR = get_path(config["data"], 'raw')
TRIMMED_DIR = get_path(config["data"], 'trimmed')
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

        pigz -p {threads} {params.outdir}/{wildcards.acc}_1.fastq
        pigz -p {threads} {params.outdir}/{wildcards.acc}_2.fastq
        """

rule trim:
    input:
        r1=f"{RAW_DIR}/{{acc}}_1.{FASTQ_SUFFIX}.{GZIPPED_SUFFIX}",
        r2=f"{RAW_DIR}/{{acc}}_2.{FASTQ_SUFFIX}.{GZIPPED_SUFFIX}",
    output:
        r1=f"{TRIMMED_DIR}/{{acc}}_1.{FASTQ_SUFFIX}.{GZIPPED_SUFFIX}",
        r2=f"{TRIMMED_DIR}/{{acc}}_2.{FASTQ_SUFFIX}.{GZIPPED_SUFFIX}",
    threads: 3
    params:
        tmp_1 = f"{TRIMMED_DIR}/{{acc}}_val_1.fq.gz",
        tmp_2 = f"{TRIMMED_DIR}/{{acc}}_val_2.fq.gz",
        outdir = TRIMMED_DIR
    shell:
        r"""
        trim_galore --paired \
                    --cores {threads} \
                    --gzip \
                    --basename {wildcards.acc} \
                    --output_dir {params.outdir} \
                    --polyA \
                    {input.r1} {input.r2}

        mv {params.tmp_1} {output.r1}
        mv {params.tmp_2} {output.r2}
        """