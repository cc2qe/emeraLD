#!/usr/bin/Rscript

## this function provides a simple R interface to emeraLD

emeraLD2R <- function(path, bin = "bin/emeraLD"){
	require(data.table)
	if(!file.exists(bin)) stop(paste0("bin = '", bin, "' file does not exist"))
	function(region, matrix.out = TRUE, info.out = TRUE){
		require(data.table)
		opts <- paste(c("--matrix", "--stdout")[c(matrix.out, TRUE)], collapse = " ")
		chr <- strsplit(region, ":")[[1]][1]
		vcfile <- gsub("\\$chr", chr, path)
		print(vcfile)
		if(!file.exists(vcfile)) stop(paste0(vcfile, " does not exist"))
		out <- suppressMessages(fread(
			input  = paste(bin, "-i", vcfile, "--region", region, opts), 
			header = FALSE, showProgress = FALSE
		))
		info <- NULL
		if(info.out){
			info <- suppressMessages(fread(
				input  = paste("tabix", vcfile, region, "| cut -f1-5"), 
				header = FALSE, showProgress = FALSE
			))
			colnames(info) <- c("chr", "pos", "id", "ref", "alt")
		}
		if(matrix.out) out <- as.matrix(out); colnames(out) <- NULL
		list("Sigma" = out, "info" = info)
	}
}

## use "$chr" when genotype files are separated by chromosome
## "$chr" is automatically replaced when a region is specified
in_path <- "example/chr$chr.1KG.25K_m.vcf.gz"

## emeraLD2R creates an LD retrieval function 
getLD <- emeraLD2R(path = in_path)

## calling an LD retrieval function invokes emeraLD
ld_data <- getLD(region = "20:83061-92955")
## emeraLD processes genotypes; LD output is passed to R

## check LD output 
head(ld_data$Sigma[, 1:10], 10)
head(ld_data$info)
