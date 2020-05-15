### Functions for the extract script "extract_from_raster_based_on_polygon_zones.R"


#############################################################
#### Functions to select specific format files
#### Libraries used:
#install.packages("raster") #Install if necessary (Just the first time)
require(raster) # For importing rasters and shapefile
#install.packages("velox") #Install if necessary (Just the first time)
require(velox) # For fast raster processing
#############################################################

#### Function to choose a CSV file interactively, halts if the input files or folders dont exist.
##   accepts to set the default location to open in the search window.
askCSV <- function (default){
  #Interactive ask CSV file
  f <- choose.files(default = "", multi = FALSE, caption = "Select the input  *.CSV file", filters = matrix(c("CSV File","*.csv"),1,2, byrow= TRUE))
  #Open data table CSV
  inputList <- read.csv(f,stringsAsFactors=FALSE)
  #check valid filenames 
  if ((invalidInputFiles(inputList))) {
    stop("The input list has some invalid input file name") #Stop script if there are invalid filenames in the list.
  }
  return(inputList)
}

#### Function to choose a shapefile file interactively.
##   accepts to set the default location to open in the search window.
#zones <- readOGR(dsn = fgdb, layer = roi_name) # This can read also GDB features
askSHP <- function (default){
  f <- choose.files(default = "", multi = FALSE, caption = "Select the input  *.shp file", filters = matrix(c("Shapefile","*.shp"),1,2, byrow= TRUE))
  return(shapefile(f)) # Return shapefile filename
}

#### Function to choose a raster file interactively, Allow Tif, Bsq and All
##   accepts to set the default location to open in the search window.}
askRaster <- function (default){
  f <- choose.files(default = "", multi = FALSE, caption = "Select the input raster", filters = matrix(c("BSQ","*.bsq","All","*","Tiff","*.tif"),3,2, byrow= TRUE))
  return(f) # Return raster name 
}

# Check the first 3 columns of the input files list, i.e. the raster filenames, the zones shapefile names and output folder locations for extraction, in_mode ==1
invalidInputFiles <- function(inputList){
  unexistingFiles <- !apply(inputList[,c(1:3)],2,file.exists)
  if (any(unexistingFiles)) {
    print("The following files in list don't exist")
    print(inputList[,1:3][unexistingFiles]) 
    return(TRUE)
  } else (return(FALSE)) # No invalid filenames
}

#######################################################################
#### Statistics Functions removing NA values
#######################################################################
## Median removing NA
median_na <- function(x) median(x, na.rm = TRUE)

## Mean removing NA
mean_na <- function(x) mean(x, na.rm = TRUE)

## sd removing NA
sd_na <- function(x) sd(x, na.rm = TRUE)

## 1st quartile removing NA
Q1_na <- function(x) quantile(x, prob=c(0.25), na.rm = TRUE)

## 3rd quartile removing NA
Q3_na <- function(x) quantile(x, prob=c(0.75), na.rm = TRUE)


#######################################################################
#### Functions to perform the zonal statistics on multiband rasters
#### Libraries used:
#require(raster) #is already imported in this file
#######################################################################

#### Extract vales from images
extractThis <- function(r_file,zones, outFolder, ID_field ="Name",func=median_na,buf=0,small=FALSE,band_names=""){
  ##   Imports raster as stack to allow multiple bands, uses "velox" object to make raster operations faster
  r <- velox(stack(r_file))
  #Set output name like the raster (remove extension and path from), save in the output folder
  OutTableName <- file.path(outFolder,paste0(tools::file_path_sans_ext(basename(r_file)),".csv"),fsep=.Platform$file.sep)
  ## Zonal statistics with velox/raster package 
  #Calculate buffer if necessary, buffer = 0 means no buffer
  if (buf != 0 ) {
    zones <- buffer(zones, width = buf, dissolve= FALSE)
  }
  ## With this we get a table with the values for all the plots and bands
  table <- r$extract(zones, df=TRUE, fun= func, small=small) #Extract and summarize the function, remove NA values. Returns a dataframe
  ## Set ID names from the shapefile IF field
  table$ID_sp <- zones@data[,ID_field] 
  ##Set band names if they are given
  if(band_names != "") {names(table) <- band_names}
  #Save to disk
  write.csv(table,OutTableName, row.names = FALSE)
}



