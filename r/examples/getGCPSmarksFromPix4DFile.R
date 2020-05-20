##get the GCP marks information from the Pix4D file and save in a file
## Thanks https://www.tutorialspoint.com/r/r_xml_files.htm

##Load package to read XML
library("XML")
## Select files from the project folders (that are in the WD), recursively
setwd("C:/temp/important/Hibap_2017-2018_GCPmarks/RGB_HiBAP")
p4dFiles <- list.files(getwd(),pattern = "\\.p4d$",recursive = TRUE)

##Read info from each p4f filename
for (f in p4dFiles) {
  p4d <- xmlRoot(xmlParse(file = f)) #read text (it is an XML file)
  gcps <- p4d[["inputs"]][["gcps"]] #Get GCPS info
  imgs<- p4d[["inputs"]][["images"]] # Get the list of image info
  ## Save in the folder of the .p4d file
  outpath = dirname(f) #Set ouput folder
  outfilename = tools::file_path_sans_ext(basename(f))  #set output basename
  saveXML(imgs, file.path(outpath, paste0(outfilename,"_imageGCP.XML")), fsep=.Platform$file.sep) #Save img-gcp marks info
  saveXML(imgs, file.path(outpath, paste0(outfilename,"_gcps.XML")), fsep=.Platform$file.sep) #Save gcps info
}