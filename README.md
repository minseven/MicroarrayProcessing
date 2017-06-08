## Welcome to MicroarrayProcessing

MicroarrayProcessing is to automate microarray data processing for multiple public project data.

### Step 1.

- Let's assume we have data from two projects of GSE15059 and GSE28320 only. Note that two projects are for E. coli. 
- Install R and library limmma. 
- clone this repo on your local.

### Step 2. Download raw data from GEO

I first download raw-data files from GEO (you might be able to do this with R package GEOquery for most cases. But please note that there are some cases you can't download raw data with GEOquery.) and saved raw data files of each project into separate folders of GSE15059_RAW and GSE28320_RAW.

### Step 3. Write up a metadata file.

Then I write up a metadata file that shows information about how to process two project data. The content of this file should be in metadata.txt. There are 9 columns and 19 rows (one header and 18 samples). The descriptions of columns are:
- SampleID. Unique identifier for the sample. This SampleID will be used for naming the output file for each sample. For example, if S0001 is SampleID, then the output will be S0001.txt.
- Ch. Channel information of the sample. If two-color microarray, it should be either 1 or 2.  
- SourceType. The microarray type information. It can be one of many including genepix, agilent, imagene, and so on. To see the full list, refer to http://svitsrv25.epfl.ch/R-doc/library/limma/html/read.maimages.html. Figuring out SourceType of each project raw data requires manual checking. There are multiple ways I used:
* I was able to figure out by looking at the extension of raw file. For example, files ending with gpr or gpr.gz are genepix.
* Or the source information is indicated in the header of the file. 
* Note that some files don't follow this rule if the raw files were produced from customized arrays. GSE28320 is an example. Then we first set SourceType as "generic". Then to properly process these types of files, it is a key to look into the header and get the names for the four columns. The four columns are 1) foreground intensities of Red channel (denoted as R), 2) foreground intensities of Green channel (denoted as G), 3) background intensities of Red channel (denoted as Rb), 4) background intensities of Green channel (denoted as Gb). There can be variety of column names. In the example of GSE28320, "F635 Median", "F532 Median", "B635 Median", "B532 Median" indicate R, G, Rb, Gb, respectively. In this example, F denotes Foreground, B denotes Background, 635, 532 are wavelengths of flurorescence and 635 indicates Red signal, whereas 532 indicates Green signal. Different project might name the columns differently. I can give you more examples of column names (in the order of R, G, Rb, Gb) below. The general idea is that Median is preferred over Mean, we only use Mean when Median is not available. Channel 2, Cy5, Wavelength of 6XX all correspond to Red channel. Likewise, Channel 1, Cy3, Wavelength of 5XX all correspond to Green channel. You could tell whether column is for foreground signal (SIG, F, Signal, and etc) or for background signal (BKD, B, Bkg, and etc.) pretty easily. 
    * R="F633 Median",G="F543 Median",Rb="B633 Median",Gb="B543 Median"
    * R="F685 Median",G="F580 Median",Rb="B685 Median",Gb="B580 Median"
    * R="CH2_SIG_MEAN",G="CH1_SIG_MEAN",Rb="CH2_BKD_MEAN",Gb="CH1_BKD_MEAN"
    * R="CH2",G="CH1",Rb="CH2_bg",Gb="CH1_bg"
    * R="Cy5 Signal",G="Cy3 Signal",Rb="Cy5 Background",Gb="Cy3 Background"
    * R="CH2I_MEDIAN",G="CH1I_MEDIAN",Rb="CH2B_MEDIAN",Gb="CH1B_MEDIAN"
    * R="MedA",G="MedB",Rb="MedBkgA",Gb="MedBkgB"
    * R="CH2_INTENSITY",G="CH1_INTENSITY",Rb="CH2_BK",Gb="CH1_BK"
    * R="SpotMedian-635",G="SpotMedian-532",Rb="BkgMedian-635",Gb="BkgMedian-532"
- R. The column name corresponding to foreground intensities of Red channel. 
- G. The column name corresponding to foreground intensities of Green channel.
- Rb. The column name corresponding to background intensities of Red channel.
- Gb. The column name corresponding to background intensities of Green channel.
- DirName. The directory name that houses the sample raw-data.
- FileName. The file name of the sample raw-data.

### Step 4. Run the command.

I run the R script (RunDataProcessing.R) by <code>Rscript RunDataProcessing.R metadata.txt</code>. This script will produce 18 gene expression files where the first column is ID and the second column is gene expression level.

