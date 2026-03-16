from workflow.lib.utils import get_path

OUT_DIR = config["output"]['base_root']
DIFF_ANALYSIS_DIR = get_path(config["output"],'diff_analysis')
DIFF_ANALYSIS_PLOTS_DIR = get_path(config["output"],'stat_plots')
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
        normalized_counts=f"{DIFF_ANALYSIS_DIR}/normalized_counts_vst.csv",
        normalized_object=f"{DIFF_ANALYSIS_DIR}/vsd.rds",
        deseq_object=f"{DIFF_ANALYSIS_DIR}/dds.rds"
    params:
        out_dir=DIFF_ANALYSIS_DIR,
        script=DIFF_ANALYSIS_SCRIPT
    threads: 1
    shell:
        """
        Rscript {params.script} {input.counts} {input.metadata} {params.out_dir}
        """

rule plot_bio_deg:
    input:
        vst=rules.peform_diff_analysis.output.normalized_counts,
        deg=rules.peform_diff_analysis.output.bio_deg,
        meta=f"{OUT_DIR}/metadata.tsv"
    output:
        f"{DIFF_ANALYSIS_PLOTS_DIR}/DEG_biological.png"
    threads: 1
    params:
        genes_n=50,
        script=ANALYSIS_SCRIPTS['deg_heat']
    shell:
        """
        Rscript {params.script} \
            {input.vst} \
            {input.deg} \
            {input.meta} \
            {output} \
            {params.genes_n}
        """

rule plot_stat_deg:
    input:
        vst=rules.peform_diff_analysis.output.normalized_counts,
        deg=rules.peform_diff_analysis.output.stad_deg,
        meta=f"{OUT_DIR}/metadata.tsv"
    output:
        f"{DIFF_ANALYSIS_PLOTS_DIR}/DEG_stat.png"
    threads: 1
    params:
        genes_n=50,
        script=ANALYSIS_SCRIPTS['deg_heat']
    shell:
        r"""
        Rscript {params.script} \
            {input.vst} \
            {input.deg} \
            {input.meta} \
            {output} \
            {params.genes_n}
        """

rule plot_volcano:
    input:
        rules.peform_diff_analysis.output.deseq_object
    output:
        f"{DIFF_ANALYSIS_PLOTS_DIR}/volcano_plot.png"
    params:
        out_dir=DIFF_ANALYSIS_PLOTS_DIR,
        script=ANALYSIS_SCRIPTS['volcano']
    threads: 1
    shell:
        """
        Rscript {params.script} {input} {params.out_dir}
        """

rule plot_MA:
    input:
        rules.peform_diff_analysis.output.deseq_object
    output:
        f"{DIFF_ANALYSIS_PLOTS_DIR}/MA_plot.png"
    params:
        out_dir=DIFF_ANALYSIS_PLOTS_DIR,
        script=ANALYSIS_SCRIPTS['ma_plot']
    threads: 1
    shell:
        """
        Rscript {params.script} {input} {params.out_dir}
        """

rule plot_PCA_vsd:
    input:
        rules.peform_diff_analysis.output.normalized_object
    output:
        f"{DIFF_ANALYSIS_PLOTS_DIR}/PCA_plot.png"
    params:
        out_dir=DIFF_ANALYSIS_PLOTS_DIR,
        script=ANALYSIS_SCRIPTS['pca_plot']
    threads: 1
    shell:
        """
        Rscript {params.script} {input} {params.out_dir}
        """