###################################################################################
#### Script to extract the values from multiband rasters based on vector zones ####
#### Recopilado por Lorena González,  Septiembre 2019                          ####
####___________________________________________________________________________####
#### There are two options for the Inputs: 
####  > A.
####    + A CSV file list of the raster, vector, output location and selected statistics. Headers:
####      * raster, vector_zone, output_Folder, zone_ID_field, if_buffer_size
####
####  > B.
####    + A folder that contains all rasters to process
####    + The vector to use as extraction zones
####  > C.
####    + raster
####    + vector
####
####    - Indicate the selected statistics
####    - The statistic table outputs are located at in the root folder of the raster location
####
#### For  the outputs:
####  + individual file per raster with all statistics
####  + datafile with all the bands and dates extracted per field

#### setwd() You can set the Working directory to the source file location
#### Get functions and libraries
source("functions_extract.R") #Check that this file is in the working directory
#require(raster)

tryCatch({ ## Put it all inside a handle error function
  
    ## Ask user the list of rasters and zone vectors
    in_mode <- menu(c("CSV list of inputs", "Raster Folder and vector file","Raster File and Vector File"), title="How do you want to give the inputs?",graphics = TRUE);
    
    ##Proceed to get input as preferred
    if (in_mode == 1){ #### CSV list of inputs ####
      
      #Select the CSV file with the list of inputs
      inputList <- askCSV() # read list from file
      #Extract for every input in the list
      for (i in 1:nrow(inputList)) {
        print(paste("Processing... ",i))
        extractThis(inputList[i,1],shapefile(inputList[i,2]), inputList[i,3], inputList[i,4],mean,as.double(inputList[i,5])) ## r_file,zones, outFolder, ID_field, fun=mean, buf
      }
      
    } else if (in_mode == 2 || in_mode == 3){ ## Enter inputs
      
      ##Ask for the vector with the zones
      zones <- askSHP()

      ## Ask if Buffer is necessary
      buf <- 0 ## The default is no buffer
      if_buf <- menu(c("No", "Yes"), title="Do you want to buffer the input vectors to extract? (Hint: Yes for points)",graphics = TRUE)
      if  (if_buf == 2){
        #Ask for the buffer size
        ##TODO: Add filters to deal with entering other than numbers for the buffer
        
        buf <- as.double(readline(prompt = "Type the buffer size (+Positive to grow, -negative to shrink the feature)"));
      }
      
      ## Ask user where to put the output tables
      #tFolder <- "C:\\" Set path fix
      outFolder <- choose.dir(caption = "Select folder to save output tables")
      
      if (in_mode == 2){ #### Process all rasters in a folder ####
        ## Ask user for Raster folder
        rFolder <- choose.dir(caption = "Select folder that contains the rasters to extract")
        #list the rasters inside the folder
        r_list <- list.files(path = rFolder, full.names= TRUE, pattern = "*.tif$") # Select only Tif files, for example
        ## Extract each raster
        for (r_file in r_list) {
          ####EXTRACT#### 
          print(paste("Processing...using =Name= as ID field... ",r_file))
          extractThis(r_file,zones, outFolder,ID_field ="Name",fun = mean,buf)
        }
      }
      
      if (in_mode == 3){ #### Ask for Raster file ####
        ####EXTRACT####
        r_file <- askRaster() #Get th raster name
        print(paste("Processing...using =Name= as ID field... ",r_file))
        ## Run extraction and saves output, indicate statistic
        extractThis(r_file,zones, outFolder,ID_field ="Name", fun = mean,buf)

      }
    }
    print("Finish")
  },
  error = function(e){print(c("Se produjo un error: ",e$message))},
  warning = function(e){print(paste("Hay advertencias: ", e$message))}
)