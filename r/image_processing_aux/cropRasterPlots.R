######### Crop image based on every plot of a trial in it
##### Load and associated table data and save each plot's data in a file
##### The first column of the tables is assumed to be the matching ID

#### Get functions and libraries
require("raster")
require("velox")

######################## DEFINE VARIABLES (Enter your variables)
roi_name <- choose.files(default="C:\\Dropbox\\RS_SIP") #Select plots shapefile name
roi <- shapefile(roi_name)
img_name <- choose.files("C:\\Dropbox\\RS_SIP") #Select plots shapefile
img <- velox(brick(img_name)) # get multiband image as a velox object (faster processing)
iname <- tools::file_path_sans_ext(basename(img_name)) #Basename of the image to name the outputs
gdata_name <- choose.files("C:\\Dropbox\\RS_SIP") #get ground table data
gdata <- read.csv(gdata_name) #Load the ground data text file, first column is the ID
outFolder <- choose.dir() #Choose output folder
print(paste("Output folder:",outFolder))

######################### STARTs SCRIPT 
#Error handling try
tryCatch({
  start.time <- Sys.time() #Check when the tool starts
    #loop for all the plots to crop, one by one 
    for (i in 1:dim(roi)[1]){
      #to crop, get a copy of the full image
      vimg <- img
      vimg$crop(extent(roi[i,])) # Apply crop (Velox package)
      r_cr <- vimg$as.RasterStack() #Convert velox to raster to be able to mask it
      #-#r_cr <- crop(img, extent(roi[i,])) # crop by roi (Raster method, bit slower alternative)
      r_cr_mk <- mask(r_cr,roi[i,])#Mask to remove what is outside the poligon and inside the rectangular extents
      #save the bands of the raster separately
      for (b in 1:img@file@nbands) {
        #name for output file. use the img name and the first column of the shapefile data as ID
        outName <- paste0(iname,"_",roi@data[i,1])
        outName <- gsub("/", "_", outName)#Remove backslash from name (if there was inside the 1st column data)
        #Name and Save file
        outFile <- file.path(outFolder,paste0(outName,"_B",b,".tif"),fsep=.Platform$file.sep)
        writeRaster(r_cr_mk[[b]], file=outFile,datatype='FLT4S',format="GTiff",overwrite=FALSE)
        #inform about saving
        print(paste("saved raster:",outFile," Succesfully"))
      }#For bands
      ## Save the data of this plot in a text file, matching with the ID in the table
      outFileData <- file.path(outFolder,paste0(outName,".csv"),fsep=.Platform$file.sep)
      plot_data <- gdata[gdata[,1] == roi@data[i,1],]#compare the ID in column 1 shapefile-table
      write.csv(plot_data,outFileData, row.names = FALSE) #write table in disk
    }#For plots
  print (Sys.time() - start.time) #print time
})#Try