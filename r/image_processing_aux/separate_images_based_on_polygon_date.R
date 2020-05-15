## Script to get the images corresponding to the area inside a polygon from a folder and separate images from fidderent dates inside same ROI in different folders.
## Assuming the Coordinate system of the geotagg is WGS84
## For RedEdge camera imagery and any other
## Recursively searches pictures inside subfolders (recursive = TRUE)
## Set for TIF FILES
## November 2019
############################issues known:
## + Check the "date" column name" to make sure that is the date you want to consider (eg. modify, create, update date...)
## + The metadata field names are fixed, may need adjusting to every specific case.
## + If the camera stopped capturing unexpetectedly, a metadata issue can rise because there will be NA values in the table

### Librarys
require(rgdal) #for intersect!
require(exiftoolr) #metadata
require(raster) # To open the shapefile
#require(rgeos) #for intersect?

## Functions

tryCatch({
  
  ##Picture folder location <-> WD
  wd <- choose.dir(caption="Select the folder with the imagery. (Recursive = TRUE)")
  setwd(wd) #set the image folder as the working directory
  
  #### Read ROI polygon of the areas of interest.
  ## Consider giving a margin in the roi to include images just outide the border that cover well the area
  ## Interactively asks the ROI shapefile filename
  ## ROI 1
  roi_filename <- choose.files(default = "", multi = FALSE, caption = "Select the input  *.shp file", filters = matrix(c("Shapefile","*.shp"),1,2, byrow= TRUE)) # this is character
  roi <- shapefile(roi_filename)  # Returns selected shapefile (this is vector)
  roi_name <- tools::file_path_sans_ext(basename(roi_filename)) # Name to make folder for the ROI, removed path and extention
  roi <- spTransform(roi,CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))#Reproject to have on the same CRS as the images (assumed to be WGS84)
  dir.create(roi_name) # Create ROI folder
  
  ## Choose the type of images to work with
  cam <- menu(c("RedEdge","Other"),title = "Choose the type of images to work with", graphics = TRUE)
  ## Proceed depending on the type of imagery
  if (cam == 1){ # Read only the first band, to read faster (but all bands will be copied)
    ## List images in folder. *.tif type is used.
    #you can use the recursive = TRUE parameter if you want to read the subdirectories
    pictures <- list.files(wd,pattern = "_1\\.tif$",recursive = TRUE) #get filenames of the first band
  } else if( cam ==2){ ## Read every picture
    ## List images in folder. *.tif type is used.
    #you can use the recursive = TRUE parameter if you want to read the subdirectories
    pictures <- list.files(wd,pattern = "\\.tif$",recursive = TRUE) #get filenames of the first band
  }
    
  ##Get metadata from the pictures
  meta <- exif_read(pictures) #get metadata from files. This takes up to 11 min if there are ~11K pictures from RedEdge camera...
  ##to do: remove images with NA (if error ocurred at capture time and metadata is incomplete)++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ EDITING
  ## Get the coordinates and image name for each picture. Check the column name matches the metadata name
  imgfileName <- as.data.frame(meta[,c("SourceFile","FileModifyDate")]) #filenames of each image and date
  # This in not working fine apparently but give it a try... filter <- !is.na(imgfileName) #get a boolean list of what is data and what has NA's
  #imgfileName <- imgfileName[filter[,1],] # Remove the records with NA's in the coordinates
  lat_long <- as.data.frame(meta[,c("GPSLongitude","GPSLatitude")]) # Data frame of the coordinates
  # lat_long <- lat_long[filter[,1],] #Avoid frames with NAs
  ######### This in not working fine apparently but give it a try... filter2 <- !is.na(lat_long)
  # lat_long <- lat_long[filter2[,1],] #Avoid frames with NAs
  #imgfileName <- as.data.frame(imgfileName[filter2[,1]]) # Remove the records with NA's in the coordinates
  ##to do: remove images with NA (if error ocurred) +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Editing ends
  
  #### Create points based on the coordinates of the images
  img_geotagg <- SpatialPointsDataFrame(lat_long, #Coords
                                        imgfileName, #Data i.e. 
                                        proj4string = CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")) #CRS
  
  # Get points that fall inside the ROI polygon
  in_poly_img <- raster::intersect(img_geotagg, roi) # get point candidates, that match the target ROI polygon rectangular extent area 
  #in_poly_img_list <- as.character(in_poly_img$imgfileName) #list of file names that match
  #in_poly_img_list <- as.character(in_poly_img$`imgfileName[filter2[, 1]]`) #list of file names that match. . ^Having some troubles matching the data types of the functions
  #in_poly_img_list <- as.character(in_poly_img@data) #list of file names that match . ^Having some troubles matching the data types of the functions
  in_poly_img_list <- in_poly_img@data #Get the dataframe from the interrsected points
  message(nrow(in_poly_img_list)," images are inside the selected polygon ",roi_name)

  ## Date formating
  #TODO: here only call the images that are inside the roi
  datestime <- in_poly_img_list$FileModifyDate #Read the date character. Make sure this is the column that has the date that you want.
  dates <- as.Date(datestime, format = "%Y:%m:%d") #format as date (this ignores the time)
  in_poly_img_list$dates <- dates # add the formated date to the selected images metadata table
  u_dates <- unique(dates) # Get the unique dates
  
  ## For every date, copy the pictures into corresponding folder
  for (i in 1:length(u_dates)){
    folder <- file.path(roi_name,u_dates[i], fsep = .Platform$file.sep) #date folder name, inside roi Folder
    dir.create(folder) # create the date folder inside the the roi folder.
    date_img_list <- in_poly_img_list[in_poly_img_list$dates %in% u_dates[i],"SourceFile"] #Subset from the metadata table only the records that have the selected date, only the file name
    #Copy the images inside ROi to the new folder roi/date
    if (cam == 1){## For the RedEdge, I worked only with one band, but want to move all the bands to the new folder
      
      ## copy all 5 bands
      for (bandn in 1:5) {
        files_copy <- file.copy(gsub("_1\\.tif",paste0("_",bandn,"\\.tif"),date_img_list), folder)
        #the previous line can give this error "more 'from' files than 'to' files" if.. (when the folder is created one level upper than necessary {OR IF SOME IMAGES WERE MOVED?})
        #### you can DELETE after copy to "MOVE" the files
        #file.remove (gsub("_1\\.tif",paste0("_",i,"\\.tif"),date_img_list)) 
      }
    } else if( cam ==2){
      
      ## Copy all based on the list to the nes folder
      files_copy <- file.copy(date_img_list, folder)
      #the previous line can give this error "more 'from' files than 'to' files" if.. (when the folder is created one level upper than necessary {OR IF SOME IMAGES WERE MOVED?})
      #### you can DELETE after copy to "MOVE" the files
      #file.remove (date_img_list) 
    }
    message(sum(files_copy)," files copied to ", folder, " folder")
  }

},
  error = function(e){print(c("An error ocurred: ",e$message))}
  #,warning = function(e){print(paste("There are warnings: ", e$message))}
)


#view features
#plot(roi)
#plot(img_geotagg,add=TRUE)
