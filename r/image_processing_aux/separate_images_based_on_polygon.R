## Script to get the images corresponding to the area inside a polygon from a folder.
## Assuming the Coordinate system of the geotagg is WGS84
## For RedEdge camera imagery
#April 2019
############################issues arrised. Check code

### Librarys
require(rgdal) #for intersect!
require(exiftoolr) #metadata
#require(rgeos) #for intersect?


##WD of the picture location
wd <- choose.dir()
setwd(wd) #interactive selection of Wording directory

## Read ROI polygon
########### This is where you select the ROI of the areas of interest ######### %$"#
roi_location = file.path("C:","Dropbox", "data","AG","vectoriales", fsep = .Platform$file.sep)
roi_name= "bc2__ag__roi_extended"                                    
roi <- readOGR(dsn = roi_location, layer = roi_name)
#Reproject to have on the same CRS as the images
roi <- spTransform(roi,CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))

##Know the positiono f each picture
#you can use the recursive = TRUE parameter if you want to read the subdirectories
pictures <- list.files(wd,pattern = "\\.tif$",recursive = TRUE) #get filenames
meta <- exif_read(pictures) #get metadata from files. This takes up to 11 min if there are ~11K pictures from RedEdge camera...
##to do: remove images with NA (if error ocurred)++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ EDITING
## Get the coordinates and image name for each picture
imgfileName <- as.data.frame(meta$SourceFile) #filenames of each image
# This in not working fine apparently but give it a try... filter <- !is.na(imgfileName) #get a boolean list of what is data and what has NA's
#imgfileName <- imgfileName[filter[,1],] # Remove the records with NA's in the coordinates

lat_long <- as.data.frame(meta[,c("GPSLongitude","GPSLatitude")]) # Data frame of the coordinates
# lat_long <- lat_long[filter[,1],] #Avoid frames with NAs
######### This in not working fine apparently but give it a try... filter2 <- !is.na(lat_long)
# lat_long <- lat_long[filter2[,1],] #Avoid frames with NAs
#imgfileName <- as.data.frame(imgfileName[filter2[,1]]) # Remove the records with NA's in the coordinates

##to do: remove images with NA (if error ocurred) +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Editing ends
img_geotagg <- SpatialPointsDataFrame(lat_long, #Coords
                                      imgfileName, #Data i.e. 
                                      proj4string = CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")) #CRS
#view features
#plot(roi)
#plot(img_geotagg,add=TRUE)

# Get points that fall inside the ROI polygon
in_poly_img <- raster::intersect(img_geotagg, roi) # get point candidates, that match the target ROI polygon area 
#in_poly_img_list <- as.character(in_poly_img$imgfileName) #list of file names that match
#in_poly_img_list <- as.character(in_poly_img$`imgfileName[filter2[, 1]]`) #list of file names that match. . ^Having some troubles matching the data types of the functions
in_poly_img_list <- as.character(in_poly_img$`meta$SourceFile`) #list of file names that match . ^Having some troubles matching the data types of the functions
message(length(in_poly_img_list)," images are inside the polygon ",roi_name)

## copy in-polygon images to separate folder
dir.create(file.path(wd,roi_name, fsep = .Platform$file.sep)) #create folder with the roi name in the same location as the image folder directory
files_copy <- file.copy(in_poly_img_list, roi_name) #can give this error "more 'from' files than 'to' files" if.. (when the folder is created one level upper than necessary {OR IF SOME IMAGES WERE MOVED?})
#file.remove (in_poly_img_list) #you can delete after copy to "move"
message(sum(files_copy)," files moved to ", roi_name, " folder")
