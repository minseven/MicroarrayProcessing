#####################################################################
# Usage: Rscript RunDataProcessing.R metadata.txt
# Function: this script reads metadata.txt as command line argument
# and saves gene expression data for each of samples in metadata.txt
#####################################################################

library(limma) # you would need to install limmar package before loading it. for more information, https://bioconductor.org/packages/release/bioc/html/limma.html

args<-commandArgs(TRUE)
mdata<-read.table(args[1],header=T,sep=",")
dirs<-unique(mdata$DirName) # get unique directory names in metadata.txt
for (dir in dirs) { # for each of directory
	cat("[Procesing] ",dir,"\n")
	flist<-unique(mdata[mdata$DirName==dir,"FileName"])
	slist<-unique(mdata[mdata$DirName==dir,"SampleID"])
	meta<-unique(mdata[mdata$DirName==dir,c("SourceType","R","G","Rb","Gb")])
	if (length(meta$SourceType) != 1) {
		cat("[Error] source type is expected to be one per project dir (",dir,")\n")
		next
	}
	if (meta$SourceType == "generic") {
		data<-read.maimages(files=flist,path=dir,columns=list(R=as.character(meta$R),G=as.character(meta$G),Rb=as.character(meta$Rb),Gb=as.character(meta$Gb)),annotation=c("Name"))
	} else {
		data<-read.maimages(files=flist,path=dir,source=as.character(meta$SourceType))
	}
	data.bgcorrected<-backgroundCorrect(data,method="normexp",offset=50) # background noise correction
	for (i in 1:length(slist)) { # for each sample, we save gene expression levels in a seprate file
		ch<-mdata[mdata$SampleID==slist[i],"Ch"]
		if (ch == 1) {
			sample.data<-log2(data.bgcorrected$G[,ceiling(i/2)]) # Green channel data corresponds to Ch1 
		} else if (ch == 2) {
			sample.data<-log2(data.bgcorrected$R[,ceiling(i/2)]) # Red channel data corresponds to Ch2
		}
		sample.data<-data.frame(data.bgcorrected$genes$Name,sample.data)
		colnames(sample.data)<-c("ID","Exp")
		write.table(sample.data,paste0(slist[i],".txt"),quote=F,sep=",",row.names=F,col.names=T)
	}
}
