#### Code to test the FIELDimageR package

## Install packages
#install.packages("devtools")
#library(devtools)
#devtools::install_github("filipematias23/FIELDimageR")
#install.packages("sp")
#install.packages("raster")
#install.packages("rgdal")

library(FIELDimageR)
library(raster)

#set wd

#Build the plot shapefile
EX1<-stack(choose.files()) # Load image
plotRGB(EX1, r = 1, g = 2, b = 3) #plot image
EX1.Rotated<-fieldRotate(mosaic = EX1, clockwise = T) #Roteate the image
## You can remove soil, etc.

## Generate the plots field map
## Import the plot Ids
DataTable<-read.csv("DataTable.csv",header = T)  
fieldMap<-fieldMap(fieldPlot=DataTable$Plot, fieldRange=DataTable$Range, fieldRow=DataTable$Row, decreasing=T)
##Now generate the plots
EX1.Shape<-fieldShape(mosaic = EX1.Rotated, ncols = 3, nrows = 3, fieldMap = fieldMap, fieldData = DataTable, ID = "Plot")
#EX1.Shape$fieldShape@data #Retrieve data 
##Plot
plot(EX1[[1]])
plot(shape, add= TRUE)     