from workflow.lib.utils import get_path


OUT_DIR = config["output"]['base_root']
ANALYSIS_DIR = get_path(config["output"],'bio_analysis')
DIFF_ANALYSIS_DIR = get_path(config["output"],'diff_analysis')
ANALYSIS_SCRIPTS = config['analysis_scipts']['bio']

rule get_top_down_list:
    input:
        f"{DIFF_ANALYSIS_DIR}/DEG_stat_diff.csv"
    output:
        f"{ANALYSIS_DIR}/top_down_list.tsv"
    threads: 1
    params:
        script=ANALYSIS_SCRIPTS['top_list'],
        gene_count=3
    shell:
        """
        Rscript {params.script} {input} {output} {params.gene_count}
        """

rule perform_ora:
    input:
        f"{DIFF_ANALYSIS_DIR}/DEG_stat_diff.csv"
    output:
        dotplot = f"{ANALYSIS_DIR}/ora_dotplot.png",
        barplot = f"{ANALYSIS_DIR}/ora_barplot.png"
    threads: 1
    params:
        script=ANALYSIS_SCRIPTS['ora'],
        go_count=20,
        out_dir=ANALYSIS_DIR
    shell:
        """
        Rscript {params.script} {input} {params.out_dir} {params.go_count}
        """

rule perform_gsea:
    input:
        f"{DIFF_ANALYSIS_DIR}/GSEA_list.rnk"
    output:
        dotplot_go_up = f"{ANALYSIS_DIR}/gsea_go_dotplot_up.png",
        dotplot_go_down = f"{ANALYSIS_DIR}/gsea_go_dotplot_down.png",
        dotplot_mig_up = f"{ANALYSIS_DIR}/gsea_msigdb_dotplot_up.png",
        dotplot_mig_down = f"{ANALYSIS_DIR}/gsea_msigdb_dotplot_down.png",
        top_go = f"{ANALYSIS_DIR}/gsea_go_top1.png",
        top_mig = f"{ANALYSIS_DIR}/gsea_msigdb_top1.png"
    threads: 1
    params:
        script=ANALYSIS_SCRIPTS['gsea'],
        out_dir=ANALYSIS_DIR
    shell:
        """
        Rscript {params.script} {input} {params.out_dir}
        """

rule perform_pear:
    input:
        f"{DIFF_ANALYSIS_DIR}/GSEA_list.rnk"
    output:
        html = f"{ANALYSIS_DIR}/gsea_pear.html",
        png = f"{ANALYSIS_DIR}/gsea_pear.png"
    threads: 1
    params:
        script=ANALYSIS_SCRIPTS['apear'],
        out_dir=ANALYSIS_DIR,
        n_paths=100
    shell:
        """
        Rscript {params.script} {input} {params.out_dir} {params.n_paths}
        """