#Arrange tables from zonalStatistics Extraction
#Take all the tables from and put in one Excel table
#Ment to be used in data of one unique experiment
# Used Packages
options(java.parameters = "-Xmx30000m") #available RAM for JAVA
library(foreign)
library(xlsx)
library(stringr)
library(plyr)
library(gtools)
#get the data processing functions
source((file.path("F:","Dropbox","Software","Scripts","r","functions_data.R", fsep = .Platform$file.sep)))

###############InputInputInputInputInputInputInputInputInputInputInput
#InputInputInputInputInputInputInputInput
#Input should be a dbf file 



id = "plot" # For most of the cases
feature = "b2s" ##buf for the BW trials


### FUNCTIONS
#######################################################

addBandToColumn <- function (f){
  t <- read.dbf(f)
  t <- subset(t, select=c(id,"MEAN"))
  band <- str_extract(f, "B[0-9][0-9]*[0-9]*") #Get the band #
  origFields <- colnames(t)
  colnamesB <- origFields
  #Next put the band number in the column but not in the id column
  for (i in 1:length(colnamesB) ){
    if (colnamesB[i] != id)
      colnamesB[i]<- paste(colnamesB[i],"_",band,feature, sep="")  
  }
  colnames(t)<- colnamesB
  return (t)
}
#Merge to use with reduce sucessively by "id"
merge.all <- function(x, y) {
  merge(x, y, all=TRUE, by=id)
}

#read tables
#################   Check these inputs#########################
#wd<-("C:\\pruebas\\")
wd <- "C:\\Users\\CIMMYT\\Documents\\ArcGIS"
setwd(wd)
getwd()

#Sequoia band wl
bandWl <- c(
  "R550",
  "R660",
  "R735",
  "R790")

#change inputs on top

#Get all the dbf names in the directory
allDbfFiles <-list.files(pattern="\\.dbf$")
#Get the unique name if disregarging the Band # and extention
unames <- unique(gsub("B[0-9][0-9]*[0-9]*.dbf", "", allDbfFiles))
#Name of the workbook 
wbookName <- paste("data_sq_vi",".xlsx",sep="")
wbook <- createWorkbook()
## Siterate through the unique filenames to put in excel
for (i in unames){
  print(paste("Nombres únicos:",i))
  pattern= paste(i,".*dbf$",sep="")
  wbSheet <- createSheet(wb = wbook, sheetName = toString(i))
  file_list = list.files(pattern=pattern)#list and filter dbf from ws
  file_list <- mixedsort(file_list)#Natural sorting
  # batch read all into a list
  t.list = lapply(file_list, addBandToColumn)
  #merge bands into a single data frame
  tables <- Reduce(merge.all, t.list)
  #Next remove the duplicate "id" column
  tables <- tables[,!duplicated(colnames(tables), fromLast = TRUE)]
  #Assign bandname wavelength 
  colnames(tables) <- c("Plot",bandWl)
  ### Calculate the VIS! (append them to the table)
  table_vi <- VI_sequoia_tab(tables)
  startRow<-1
  print(paste("Escribiendo",nrow(tables),"registros en",i))
  addDataFrame(x=table_vi, sheet=wbSheet,row.names=FALSE,startRow = startRow)
}
saveWorkbook(wbook, wbookName)
print(paste("Se guardó el archivo",wbookName))

