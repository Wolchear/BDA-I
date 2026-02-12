from snakemake.utils import min_version
min_version("6.0")

from workflow.lib.utils import get_path

configfile: "config.yaml"

SUFFIX = config["suffix"]
DATA = config['data']
SRA = config['sra']

rule all:
    input:
        # data/raw/{acc}_1\2.fastq
        expand(
            "{data_dir}/{acc}_{paired}.{suffix}",
            data_dir=get_path(DATA,'raw'),
            acc=SRA,
            suffix=SUFFIX["fastq"],
            paired = ['1', '2']
        )




RULES_DIR = get_path(config['workflow'], "rules")

module raw_data:
    snakefile: f"{RULES_DIR}/raw_data.smk"
    config: config
use rule * from raw_data