#Arrange tables from zonalStatistics Extraction
#Take all the tables from a in different DBF files of zonal statistics and put in one same table all the rowsdate-cam and put in one Excel table
#Input should be dbf files 

# Used Packages
library(foreign)
#library(xlsx)
library(stringr)
library(plyr)
#library(gtools)
library(reshape2)
library(corrplot)
library(psych)
library(ggplot2)
library(plotly)
library(ggpmisc)

#######################################################
### FUNCTIONS
#######################################################

readTables <- function (f){
  ##read dbFfile
  t <- read.dbf(f)
  
  ##know name of the file without extention
  f_noExt <- gsub(".dbf","",f)
  #Separate the Field name, date and VI from the table name
  metadata <- unlist(strsplit(f_noExt, "_"))
  ##Add the data to new columns
  t$id <- paste0(metadata[1],"_",metadata[2]) #Field 
  t$field <- metadata[1] #Field 
  t$date <- metadata[2] #Date 
  t$VI <- gsub('B1','',metadata[3]) #VI 
  return (t)
}

#value_field can be 'MEAN_NORM_DIAS' or 'MEAN'
separateInColumnsbyTheVIs <- function(table,value_field){
  ##Separate in columns the VIs for each date -- Wide table
  #Change back from long to wide table
  # a "formula object" is used in the  form: varDependent ~ varIndependent
  wtable <- dcast(table, boleta+Campos+WG+DG+W400+HT+PB+PN+N_PERCENT+rich_strip ~ 
                    VI+num_medicion, value.var=value_field)
  
  #tabla temporal para anadir atributos por fecha en columnas
  #Days from sowing to image capture
  t_dias <- dcast(table, boleta ~ num_medicion, value.var='dias_siembra_a_imagen',fun=mean)
  t_dias[is.na(t_dias)] <- NA #and remove NaNs
  colnames(t_dias)[2:4] <- paste0("dias_siembra_a_img",colnames(t_dias)[2:4])
  
  #ISSUES in images
  t_issues <-dcast(table, boleta ~ num_medicion, value.var='ISSUES',fun=mean) 
  t_issues[is.na(t_issues)] <- NA #and remove NaNs
  colnames(t_issues)[2:4] <- paste0("ISSUES_img",colnames(t_issues)[2:4])
  
  #Fecha de toma de imagen
  table$date <- as.numeric(table$date) #Use the date as numeric to be able to summarize it
  t_date_img <-dcast(table, boleta ~ num_medicion, value.var='date',fun=mean)
  t_date_img[is.na(t_date_img)] <- NA #and remove NaNs
  colnames(t_date_img)[2:4] <- paste0("date_img",colnames(t_date_img)[2:4])
  
  #Join to wtable
  table_complete <-merge(wtable,t_dias,by="boleta") #Add dias_siembra_a_imagen
  table_complete <-merge(table_complete,t_issues,by="boleta") # Add issues column
  table_complete <-merge(table_complete,t_date_img,by="boleta") # Add capture date
}

getTable <- function(wd,m,n){
  setwd(wd)
  
  n[is.na(n)] <- NA #remove no data(.)
  n <-n[ ! n$N_PERCENT %in% '.', ]
  n$N_PERCENT<-as.numeric(n$N_PERCENT) 
  #Get all the names of the DBFs to read
  allDbfFiles <-list.files(pattern="\\.dbf$")
  
  ## Put together all the rows of the different tables with the custom function "readTables" into a list
  #Read all the files to a list
  tables.list = lapply(allDbfFiles,readTables)
  #Merge with row bind tool into one table
  table_ <- Reduce(rbind, tables.list)
  #Merge VIs table with metadata
  table_m <-merge(table_,m,by="id")
  #Merge VIs table with the Nitrogen content data
  table <-merge(table_m,n,by="boleta")
  #dividir los indices entre dias de siembra y dia a la toma
  table$MEAN_NORM_DIAS <- table$MEAN/table$dias_siembra_a_imagen 
  #Edicion de boletas de JASP para que no se combinen con las de Lupita14
  table$boleta[table$Campos=='jasp']<-paste0('0',table$boleta[table$Campos=='jasp'])
  #return the table
  return(table)
}
##Save table
#write.csv(wtable,"Tabla.csv", row.names=FALSE)
