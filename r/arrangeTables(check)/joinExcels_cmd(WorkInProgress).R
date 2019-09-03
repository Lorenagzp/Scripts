#####################################################################
# Title: Merge excels in one excel- to be executed from the command line (right clic and send to script with a bat file).





#WORK IN PROGRESSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS






#It can accept multiple input files to execute the tool on all of them
#####################################################################

### Load required libraries
library(xlsx)
#get the data processing functions
source((file.path("F:","Dropbox","Software","Scripts","r","functions_data.R", fsep = .Platform$file.sep)))

### set filename of INPUT files
#file<-""   ### get file name fixed mode (this could be actually a list of files)
args <- commandArgs(TRUE) #Get from the command line
#TODO: Filter for only Excel files

### nos posicionamos en el directorio de trabajo ###
#work.dir <- "C:\\pruebas"  ### To Change the input directory manually
work.dir <-dirname(normalizePath(args[1])) #get the WD from the input files
setwd(work.dir) #Set the working directory
getwd() # show the working directory


print("Files to process")

xl <-(0)
for (arg in 1:length(args)) {
  print(paste0("##### Current file processing...  ", args[arg])) #Print name of file
  #Open the excel file to get the data, read the entire first sheet
  xl[arg] <- read.xlsx2(args[arg], sheetIndex = 1, stringsAsFactors=FALSE)

  ## Write the excel file
  print(paste0("writing: xls",".xlsx"))
  write.xlsx(x = xl[arg], file = ,paste("xls",".xlsx",sep=""),
             sheetName =   as.character(arg), row.names = FALSE)

}
print("########## Success in execution!")




################################## Manually join...

xls <- choose.files(default = (file.path("F:","Dropbox","data","AE","seed", fsep = .Platform$file.sep)), caption = "Select Excel files",
             multi = TRUE, filters = Filters,
             index = nrow(Filters))
xls_data <-list()
for (x in 1:length(xls)) {
  xls_data[[x]] <-  read.xlsx2(xls[x], sheetIndex = 1, stringsAsFactors=FALSE)
}

xs <- lapply(xls_data,rbind)
             