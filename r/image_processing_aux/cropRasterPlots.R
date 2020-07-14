######### Crop image based on every plot of a trial in it
######### Load and associated table data and save each plot's data in a file
##### The FIRST column of the tables is assumed to be the matching ID
##### Outputs saved in the img_path level
##### the script is working with specific trial colum names when saving the ground data for the plot
##### Example image name: a160407tsccel.tif
##### Date in the image name expected in a format yymmdd, also in the visual scrore data

#### Get functions and libraries
require("raster") # For raster procesing
require("stringr") #to match string expressions

#########################Function to crop the raster based on the polygons of a shapefile.
### Function INPUTS
### img_name (a raster filename)
### roi (a polygon shapefile representing plots/zones to crop. The first column of the table is used as ID)
### gdata (a dataframe with information about every plot. The first column of the table is used as ID)
### outFolder (folder where to save the output cropped images and tables)
##### require("raster") # Package
cropRasterPlots <- function(img_name,roi,gdata,outFolder){
  img <- stack(img_name) # get multiband image
  img <- crop(img, extent(roi)) #Crop image to the full extent of all the plots
  iname <- tools::file_path_sans_ext(basename(img_name)) #Basename of the image to name the outputs
  idate <- str_extract(iname, "(\\d){6}") # Expression to match the 6 digits in the iname -> date of acquisition
  ##loop for all the plots to crop, one by one 
  plotsID <- unique(roi@data[,1]) #Get the unique-ID plots from the first column of the table
  for (id in plotsID){ 
    roi_plot <- roi[roi@data[,1] == id,] #get the polygon for this ID, compare 1st column of table
    r_cr <- crop(img, extent(roi_plot)) # crop by plot roi (raster package)
    r_cr_mk <- mask(r_cr,roi_plot)#Mask to remove what is outside the poligon and inside the rectangular extents
    #set name for output file use the img name and the plot ID
    outName <- paste0(iname,"_",id)
    ##save the bands of the raster separately, iterate through all the raster's bands
    for (b in seq_len(dim(r_cr_mk)[3])) { #get the number of bands from the dimensions of the raster, 3rd parameter (r,c,bands)
      #Name and Save file
    outFile <- file.path(outFolder,paste0(outName,"_B",b,".tif"),fsep=.Platform$file.sep) #Add band no. to name
      writeRaster(r_cr_mk[[b]], file=outFile,datatype='FLT4S',format="GTiff",overwrite=FALSE)
      #inform about saving
    print(paste("saved raster:",outFile))
    }#For bands End
    ## Name, select and Save the data of this plot in a text file, matching with the ID in the table
    outFileData <- file.path(outFolder,paste0(outName,".csv"),fsep=.Platform$file.sep)
    #compare the first column of the table with plotID, select desired columns (visual score only from the image date)
    plot_data <- gdata[gdata[,1] == id,c("Name","REP","BLK","PLOT","ENTRY","trial",paste0("TSC",idate),"Yield")]
    write.csv(plot_data,outFileData, row.names = FALSE) #write table in disk
  }#For plots End
}#cropRasterPlots Function End

######################## DEFINE VARIABLES (Enter your variables, interactive menus)
##Shapefile
myPath ="C:\\Dropbox\\RS_SIP\\Analysis\\AGF"
roi_name <- choose.files(default=myPath, caption = "Select shapefile") #Select plots shapefile name
roi <- shapefile(roi_name) # Open the shapefile
roi_basename <- tools::file_path_sans_ext(basename(roi_name)) #Get the roi name only
print(paste("Shapefile:",roi_name))
## Image or image list
##img_name <- choose.files("C:\\Dropbox\\RS_SIP",caption = "Select image") #Select plots shapefile
img_path <- choose.dir(default=myPath,caption="Select folder with rasters to clip")
img_list <- list.files(path=img_path,pattern = "\\.tif$|\\.bsq$",full.names = TRUE)
print(paste("Image folder:",img_path))
## Data
gdata_name <- choose.files(default=myPath, caption = "Select CSV table data with ground data") #get ground table data
gdata <- read.csv(gdata_name) #Load the ground data text file, first column is the ID
print(paste("Ground data:",gdata_name))
## Output folder
#outFolder <- choose.dir(default=myPath,caption ="Select output folder") #Choose output folder
outFolder <- file.path(img_path,paste0("crop_",roi_basename),fsep=.Platform$file.sep) #Set the output folder in the img_path + roi name
dir.create(outFolder) # create the output folder if doesnt exists
print(paste("Output folder:",outFolder))

######################### STARTs SCRIPT 
#Error handling try
tryCatch({
  start.time <- Sys.time() #Check when the tool starts
  #Process every image in the list
  for (img_name in img_list) {
    #crop the plots, save to the output folder
    cropRasterPlots(img_name,roi,gdata,outFolder)
  }
  print (Sys.time() - start.time) #print execution time
})#Try

