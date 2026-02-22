from workflow.lib.utils import get_path

REF_DIR = get_path(config["data"], 'references')
REF_GEN_CONF = config["ref"]['genome']
REF_ANNOT_CONF = config["ref"]['annotation']

rule get_genome:
    output:
        genome = f"{REF_DIR}/genome.fa.gz"
    params:
        link=REF_GEN_CONF['link']
    threads: 1
    log:
        f"logs/ref/{REF_GEN_CONF['file_name']}.log"
    shell:
        """
        wget -c -O {output.genome} {params.link} > {log} 2>&1
        """

rule unzip_genome:
    input:
        rules.get_genome.output
    output:
        f"{REF_DIR}/{REF_GEN_CONF['file_name']}"
    shell:
        """
        gunzip -c {input} > {output}
        """

rule get_annotation:
    output:
        annotation = f"{REF_DIR}/annotation.gtf.gz"
    params:
        link=REF_ANNOT_CONF['link']
    threads: 1
    log:
        f"logs/ref/{REF_ANNOT_CONF['file_name']}.log"
    shell:
        """
        wget -c -O {output.annotation} {params.link} > {log} 2>&1
        """

rule unzip_annotation:
    input:
        rules.get_annotation.output
    output:
        f"{REF_DIR}/{REF_ANNOT_CONF['file_name']}"
    shell:
        """
        gunzip -c {input} > {output}
        """