# RNA-seq Analysis of ESCC vs Normal Tissues

## 📌 Project Description
This project performs RNA-seq data analysis to compare gene expression profiles between normal esophageal tissues and esophageal squamous cell carcinoma (ESCC). The goal is to identify differentially expressed genes and characterize biological processes involved in tumor progression.

---

## 🧬 Data Description
RNA-seq data were obtained from the NCBI Sequence Read Archive (SRA).

- Study:
Cao, W., Lee, H., Wu, W., Zaman, A., McCorkle, S., Yan, M., Chen, J., Xing, Q., Sinnott-Armstrong, N., Xu, H., Sailani, M. R., Tang, W., Cui, Y., Liu, J., Guan, H., Lv, P., Sun, X., Sun, L., Han, P., … Bivona, T. G. (2020). Multi-faceted epigenetic dysregulation of gene expression promotes esophageal squamous cell carcinoma. Nature Communications, 11(1), 3675. https://doi.org/10.1038/s41467-020-17227-z

- Samples:
  - GSM4505876
  - GSM4505877
  - GSM4505878
  - GSM4505886
  - GSM4505887
  - GSM4505888

- Data type:
  - RNA-seq (paired-end)
  - ~37 million reads per sample

- Reference genome and annotation file:
  - GRCh38 (GENCODE Release 49)


---

## ⚙️ Software and Tools

### Workflow management
- Snakemake >=6.0.0
	- Config file: `config.yaml`

### Environment management
- Conda
	- Environment file: `environment.yml`

The analysis was performed using a Conda environment with the following dependencies:

```yaml
dependencies:
  - python=3.12
  - snakemake>=9.13.7
  - sra-tools>=3.2.1
  - seqkit>=2.12.0
  - fastqc>=0.12
  - multiqc>=1.33
  - pigz>=2.8
  - hisat2>=2.2
  - samtools>=1.2
  - matplotlib>=3.10
  - deeptools>=3.5.6
  - rseqc>=5.0
  - cutadapt>=5.2
  - subread>=2.1.1
  - bioconductor-deseq2>=1.50
  - r-ggplot2>=4.0.0
  - r-pheatmap>=1.0.13
  - r-tidyverse>=2.0.0
  - bioconductor-apeglm>=1.32.0
  - r-ggrepel>=0.9.6
  - r-rcolorbrewer
  - r-patchwork>=1.3
  - bioconductor-org.hs.eg.db>=3.22
  - bioconductor-clusterprofiler>=4.18
  - bioconductor-enrichplot>=1.30
  - r-msigdbr>=26.1
  - r-base>=4.4
  - r-devtools>=2.4
  - r-htmlwidgets>=1.6
  - r-plotly>=4.12
```


## 🔬 Analysis Overview  
  
1. Download raw sequencing data from SRA  
2. Perform quality control (FastQC, MultiQC)  
3. Trim reads (cutadapt)  
4. Map reads to reference genome (HISAT2)  
5. Perform mapping QC (RSeQC, deepTools)  
6. Quantify gene expression (featureCounts)  
7. Perform differential expression analysis (DESeq2)  
8. Conduct functional enrichment analysis (ORA, GSEA)  
9. Generate visualizations (plots, networks)  
  
---

## ▶️ How to Reproduce the Analysis  
  
### 1. Clone the repository  
```bash  
git clone https://github.com/Wolchear/BDA-I.git  
cd BDA-I
```
### 2. Create environment
```bash  
conda env create -f environment.yml  
conda activate BDA-I
```
### 3. Donwload aPEAR
Execute it, otherwise you will not be able to reproduce the [aPEAR](https://pmc.ncbi.nlm.nih.gov/articles/PMC10641035/) step
```bash  
./install_apear 
```
### 4. Run the pipeline
It is recommended to use a number of {threads} divisible by 3 and not less than 6. If 6 cores are not available, adjust the value in the config file accordingly.
```bash  
snakemake -j {threads}
```

## 📁 Output
Key results are stored in:
output/  
```bash
└── output
    ├── biological_analysis
	├── differential_gene_expression_analysis
    ├── differential_gene_expression_analysis_plots
    └── mapped
```
