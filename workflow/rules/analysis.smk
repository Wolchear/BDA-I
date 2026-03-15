from workflow.lib.utils import get_path

OUT_DIR = config["output"]['base_root']
DIFF_ANALYSIS_DIR = get_path(config["output"],'diff_analysis')

ANALYSIS_SCRIPTS = config['analysis_scipts']
DIFF_ANALYSIS_SCRIPT = ANALYSIS_SCRIPTS['diff_analysis']

rule peform_diff_analysis:
    input:
        counts=f"{OUT_DIR}/all.counts.txt",
        metadata=f"{OUT_DIR}/metadata.tsv"
    output:
        stad_deg= f"{DIFF_ANALYSIS_DIR}/DEG_stat_diff.csv",
        bio_deg= f"{DIFF_ANALYSIS_DIR}/DEG_biological_diff.csv",
        gene_list = f"{DIFF_ANALYSIS_DIR}/GSEA_list.rnk",
        normalized_counts=f"{DIFF_ANALYSIS_DIR}/normalized_counts_vst.csv"
    params:
        out_dir=DIFF_ANALYSIS_DIR,
        script=DIFF_ANALYSIS_SCRIPT
    threads: 1
    shell:
        """
        Rscript {params.script} {input.counts} {input.metadata} {params.out_dir}
        """