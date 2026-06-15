1.System requirements
-------------------------
a. We implemented the codes with MATLAB R2021a  and Python on Windows10.

2.Brief description of the document：
-------------------------
CRC_human: Files for processing and analyzing the data in the "human_cleaned_expression" table
CRC_mouse: Files for processing and analyzing the data in the "mouse_crc_mean_by_timepoint" table
human_cleaned_expression: Human colorectal cancer (CRC) gene expression data obtained from the GEO (Gene Expression Omnibus) database, with dataset ID GSE44076, which contains 44,584 samples. The expression data are based on the Affymetrix platform.
mouse_crc_mean_by_timepoint:The mouse gene expression data used in this study were also obtained from the public GEO (Gene Expression Omnibus) database, with dataset ID GSE178145. The data were generated using RNA-seq sequencing on the Illumina HiSeq2500 platform, producing 32,435 samples

The only difference between the CRC_human and theCRC_mouse is that the input dataset is different
(CRC_human and theCRC_mouse are also similar)
The following subfile descriptions apply to either file:
-------------------------
Merged data:Two datasets that hold the raw data

2.1.Data preprocessing:
	h_preprocess.m/preproces1.m：The main script for data preprocessing
	p_data.mat ：A data preprocessing function that includes the average processing of 0 values and the moving average processing of the original data
	t.mat ：Post-processing data obtained after data preprocessing
	pseudo_time_expr.xlsx/mouse_crc_mean_by_timepoint.xlsx：Collated raw data
2.2.kmeans++:
	kmeans_plusplus1.m：kmeans++ algorithm script 
	transition.m ：The gene expression time series is transformed into a function of gene dynamics (gene expression distribution)
	setHandel.m ：A function to set the drawing window size
	outpng.m ：A function that outputs a picture
	h_kmeans2.mat/m_kmeans.mat: The result of the kmeans_plusplus.m script
2.3.Build a gene network:
	h_process2.m / m_process.m：The main script for building gene networks and plot the correlation coefficients
       h_pre.mat/ m_pre.mat ：The corresponding results of constructing gene network scripts

2.4.Identify sensitive genes and gene combinations：
	2.4.1.Initial network entropy index calculation:
		h_c_index0.m/c_index0.m：A script to calculate the initial network entropy
		refine_Main_ARNN.m：ARNN function
		NN_F2.m：The function that is required to process the data in the ARNN algorithm prediction process
		Stem3D.m：A function for drawing 3D stem diagrams
		h_error.mat/ m_pre.mat：ARNN prediction error saved after running
		h_init_index.mat/m_init_index.mat：The initial overall network entropy of the output
	
	2.4.2.Disturbance handling:
		raodong_point.m ：A script that perturbs each gene to different degrees and determines whether there is a significant impact on the system after perturbation
		Butterfly.m ：A function for drawing butterflies
		StackedButterflyPlot.m ：A function that draws a stacked butterfly diagram
		h_point_result.mat /h_point_result.mat：The result of output from script raodong point.m after perturbation processing
2.5Verification
 We implemented the codes in this section with Python  on Windows10.

compare.py：Analyzes co‑expression and expression variability of sensitive genes in CRC cell lines, comparing their variance against background genes.
MLP_3.py：Performance Distribution by Repeated Stratified 3‑Fold CV
      Violin plots of multi‑metric performance from repeated stratified 3‑fold cross‑validation (with mean and 95% CI), featuring arrows on axes.
      The figure is generated and saved using the plt.savefig() command in both PNG and PDF formats.

3.Use script sequence：
-------------------------
h_preprocess.m-->kmeans_plusplus1.m-->h_process2.m -->h_c_index0.m-->raodong_point.m-->MLP_3.py--> plot
Note:  The .mat files in different folders are needed to updat during operation.
	
