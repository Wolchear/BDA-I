from snakemake.utils import min_version
min_version("6.0")

from workflow.lib.utils import get_path

configfile: "config.yaml"

SUFFIX = config["suffix"]
DATA = config['data']
OUTPUT = config['output']
SRA = config['sra']

rule all:
    input:
        # data/raw/{acc}_1\2.fastq.gz
        expand(
            "{data_dir}/{acc}_{paired_id}.{suffix}",
            data_dir=get_path(DATA,'raw'),
            acc=SRA,
            suffix=f'{SUFFIX["fastq"]}.{SUFFIX["compress"]}',
            paired_id = config['paired_id']
        ),
        # output/reports/{acc}_1\2.html
        expand(
            "{data_dir}/{acc}_{paired_id}.{suffix}",
            data_dir=get_path(OUTPUT,'reports'),
            acc=SRA,
            suffix=SUFFIX["report"],
            paired_id = config['paired_id']
        )



RULES_DIR = get_path(config['workflow'], "rules")

module raw_data:
    snakefile: f"{RULES_DIR}/raw_data.smk"
    config: config
use rule * from raw_data

module fast_qc:
    snakefile: f"{RULES_DIR}/fast_qc.smk"
    config: config
use rule * from fast_qc