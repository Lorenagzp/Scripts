##Script to merge together multiple CSV text files with the same structure and trial:
## eg. Extraction of data from aerial imagery from agronomic experiment plots

#Working with one band per table, check further comments for multiband...
files_path <- choose.dir(default="F:\\Dropbox\\RS_SIP") #Files location
files <- list.files(files_path,pattern="\\.csv$",full.names = TRUE) #list of CSV files
ts_extracted <- lapply(files,read.csv) #Batch read CSV tables in a list
id_field <- "cluster" # Set which is the ID column name 
t_all <-Reduce(function(x, y) merge(x, y, by=id_field), ts_extracted)# Merge in one table
## Renanme column with the table they came from,
## Also remove unnecesary text from the table names
new_colnames <- gsub("S2AGRI_L3B_|MONO_A20|_T12RXR","",tools::file_path_sans_ext(basename(files))) 

#### The next depends if we have one data column per table or multiband...
#### Reasign column names (ONE BAND PER TABLE)
names(t_all) <- c(id_field,new_colnames) 
#### Reasign column names (5 REDEDGE BANDS PER TABLE):
##"outer" can paste together two character vectors of different lengths
#band_names=c("Blue","Green","Red","Red Edge","NIR") #For redEdge camera
#band_names=c("Green","Red","Red Edge","NIR") #For sequoia
#names(t_all) <- c(id_field,c(t(outer(new_colnames,band_names, paste0)))) 

#### Optional operations
##Divide by 1000, if necessary (For Sentinel)
#t_all[,2:ncol(t_all)] <- t_all[,2:ncol(t_all)]/1000 #Using only the columns with values, not the ID
## Average Repetitions (the ID first char is the rep)
#t_all[,1] <- substring(t_all[,1], 2) #Remove the Rep ID and average the trials
#t_mean <- aggregate(. ~ ID, t_all, mean) # Average t_all table by ID

#Write to disk the table merged
write.csv(t_all,file.path(files_path,paste0(basename(files_path),".csv")), row.names = FALSE)
#write.csv(t_mean,file.path(files_path,paste0(basename(files_path),"_mean.csv")), row.names = FALSE)