#Script to stack the Multispectra bands from the slantrange 4 bands to be able to open in autopano to estimate coordinates later.
#Names are expected like:
# 1517337077.532nm.tif
# 1517337077.570nm.tif
# 1517337077.650nm.tif
# 1517337077.850nm.tif
# Saves in integer format to make it lighter, can be changes easily when wrinting the raster

#0. First step : load packages
#install.packages(c("rgdal","raster"))
require(raster)
require(rgdal)
library(stringr)

#Function multibandStack
slantrange3bandStack <- function(imgBasename, wd) 
{
  tryCatch({
    setwd(wd)
    #Input file with bands 1 : 532 nm
    img_basename<-imgBasename
    img_1<-paste(img_basename,'.532nm.tif',sep = "")
    imported_raster_1=raster(img_1)

    #Input file with bands 3: 650 nm
    img_3<-paste(img_basename,'.650nm.tif',sep = "")
    imported_raster_3=raster(img_3)

    #Input file with bands 4: 850 nm
    img_4<-paste(img_basename,'.850nm.tif',sep = "")
    imported_raster_4=raster(img_4)

    
    #plot(imported_raster_0) #see image just to test
    #stack 6 bands in one pile
    img=stack(list(img_1,img_3,img_4)) 
    img[img==0] <- NA #Set 0 as no data
    
    #Write the tif to disk
    writeRaster(img, file=paste(imgBasename,"stack.tif",sep = ""),datatype='FLT4S',format="GTiff",overwrite=FALSE) 
  })
}
########### START ##########################
#Working directory
wd=choose.dir()
setwd(wd)

imgFilesList <-list.files(pattern="\\.tif$")
##Next the names of the images, collapse to get one entry per pair(-0.tif and -1.tif)
#imgsPairNames <- unique(str_extract(imgFilesList, "TTC[:digit:]{5}")) #For individual frames
basenames <- unique(str_extract(imgFilesList, ".{0,10}")) #For mosaics {0,13}
## Sets the pattern of name in files to be stacked
for (i in basenames){
  print(paste("Image:",i))
  slantrange3bandStack(i, wd) 
}
print(paste("Finished merging",toString(length(basenames)),"images"))
