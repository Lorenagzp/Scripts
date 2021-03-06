#Protocol to evaluate Plant height 
#Authors: Jose Manuel Mendoza Reyes and Lorena Gonzalez Perez

#Coments specific to make it work in obreg�n marked as #L#

library (sp)
library (raster)
library(rgdal)
library(data.table)
library(plyr)
library(dplyr)


# Load the raster base (DTM)
rasterBase<- raster("G:/AE/161026/r161026fis/r161026hap/3_dsm_ortho/1_dsm/r161026hap_dsm.tif")

#Select the work directory wich are the raster file and shp
setwd(choose.dir(getwd(), "Selecciona tu archivo"))

#select the raster file (DSM)
raster <-raster(list.files(pattern = "\\.tif$"))

#L# raster<- raster("G:/AE/161026/r161026fis/r161026hap/3_dsm_ortho/1_dsm/r161026hap_dsm.tif")

#Cut the DSM base on the DTM extent
r_crop<-crop(raster, extent(rasterBase), snap="out")
#L# r_crop<-raster

#Change the spatial resolution of DTM (if it is necessary)
rasrecla <- resample(rasterBase, r_crop, resample='ngb')
#L# rasrecla <- r_crop

#Geoidal height for the area of interest (checked it on INEGI web)
n=-32.37

#Get Geoidal height base on the ellipsoidal height
r_croph <- (r_crop-n)

#Check that the two raster have the same attributes

#DTM
show(rasrecla)
#DSM
show(r_croph)

rest <-function(r1,base){(r1-base)}
plant.height <- rest(r_croph, rasrecla)
#L# plant.height <- rasterBase

# show(plant.height)
# plot(plant.height)

#select the shapefile (a shp with buffer genereted in Arcgis)
shp <- shapefile(list.files(pattern = "\\.shp$"))
#L# Select one file interactively
#L# shp <-shapefile(file.choose(new = FALSE))

#plot(plant.height)
#plot(shp, add= TRUE)

#Set the name of the outut csv table
name<-list.files(pattern = "\\.shp$")
name<-gsub(".shp", "", name)


#Write the new  plant height raster (DSM)
writeRaster(plant.height, filename= paste(name, "heightRaster_2.tif"), format = "GTiff")

#Overlap and extract the pixel value in each polygon
pixelval <- extract(plant.height,shp)

#Add the plot name to the pixel value list
names(pixelval)<- shp$Name


#check the list
#str(pixelval)

#function to eliminate soil pixels 
soil.mask <- function(p){
  p.1 = subset(p,p >0.05)
  return(p.1)
}

#Apply the mask to the list
PlantsValue <- lapply(pixelval,soil.mask)


#function to calculate and eliminate outliers
outliers <- function(dat){
n=2
a=median(dat)
b=sd(dat)
limitesuperior=(a+n*b)
limiteinferior=(a-n*b)
dat1= subset(dat,dat <= limitesuperior & dat >= limiteinferior)
return(dat1)
}

#extract the outliers
Tableclean = lapply(PlantsValue,outliers)


str(Tableclean)


#Calculate the descriptive statistics of the new list without outliers and convert it in a data base

allstats = lapply(Tableclean,summary)
sd = lapply(Tableclean, sd)
n = lapply(Tableclean, length)

#Join all the statistics calculated in one table
desc.stats.t = mapply(c,allstats,sd, n)

# Transpose the matrix
desc.stats <- t(desc.stats.t)


#Convert to data frame
df <- as.data.frame(desc.stats)

# Add the rownames as a new column
setDT(df, keep.rownames = TRUE)[]

#Rename the columns
colnames(df)[1:9]<-c("Plot", "Min", "Q1", "Median", "Mean", "Q3", "Max", "SD", "n")

#Rewrite again the data frame
df<-data.frame(df)

# Average the values using the unique ID (Plot names)
final.df=aggregate(cbind(Min, Q1, Median, Mean, Q3, Max, SD, n)~Plot,df, mean)

#write the final table
write.csv(final.df,paste(name,"_plant_Height.csv", sep=""), row.names=FALSE)







