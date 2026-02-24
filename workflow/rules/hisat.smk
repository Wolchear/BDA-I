from workflow.lib.utils import get_path

REF_DIR = get_path(config["data"], "references")
REF = config["ref"]

HISAT_DIR = get_path(config["data"], 'index')
HISAT_BUILD_PARAMS = config['hisat-build_params']

MAPPED_DIR =  get_path(config["output"], "mapped")
RAW_DIR = get_path(config["data"], 'raw')

FASTQ_SUFFIX = config['suffix']['fastq']
COMPRESSED_SUFFIX = config['suffix']['compress']
HISAT_PREFIX = f"{HISAT_DIR}/{HISAT_BUILD_PARAMS['prefix']}"

rule get_splice_sites:
    input:
        f"{REF_DIR}/{REF['annotation']['file_name']}"
    output:
        f"{REF_DIR}/splice_sites.txt"
    threads: 1
    shell:
        """
        hisat2_extract_splice_sites.py {input} > {output}
        """

rule build_index:
    input:
        genome=f"{REF_DIR}/{REF['genome']['file_name']}"
    output:
        done=f"{HISAT_DIR}/.done"
    threads: HISAT_BUILD_PARAMS['threads']
    params:
        seed=HISAT_BUILD_PARAMS['seed'],
        prefix=HISAT_PREFIX
    shell:
        r"""
        set -euo pipefail
        hisat2-build --seed {params.seed} \
                     -p {threads} \
                     {input.genome} \
                     {params.prefix}
        touch {output.done}
        """

rule align:
    input:
        idx=rules.build_index.output.done,
        ss=rules.get_splice_sites.output,
        fasta_1 = f"{RAW_DIR}/{{acc}}_1.{FASTQ_SUFFIX}.{COMPRESSED_SUFFIX}",
        fasta_2 = f"{RAW_DIR}/{{acc}}_2.{FASTQ_SUFFIX}.{COMPRESSED_SUFFIX}"
    output:
        bam = f"{MAPPED_DIR}/{{acc}}.sorted.bam",
        bai = f"{MAPPED_DIR}/{{acc}}.sorted.bam.bai"
    threads: 6
    log:
        f"logs/hisat2/{{acc}}.log"
    params:
        idx=HISAT_PREFIX
    shell:
        r"""
        set -euo pipefail

        hisat2 -x {params.idx} \
            -1 {input.fasta_1} \
            -2 {input.fasta_2} \
            -p {threads} \
            --known-splicesite-infile {input.ss} \
            --dta --very-sensitive \
            --no-mixed --no-discordant \
            2> {log} \
        | samtools view -@ {threads} -b - \
        | samtools sort -@ {threads} -o {output.bam} -

        samtools index -@ {threads} {output.bam}
        """