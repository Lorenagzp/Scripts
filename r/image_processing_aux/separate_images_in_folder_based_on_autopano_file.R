### Script to separate the files from the thermal imagery that correspond to a specific area, based on the autopano mosaic file.
### The output folder is created based on the name of the autopano file, inside the image folder upper level
### Use the full path to reference images in the pano file.
### TODO: implement error catching in the script

####################################################### FUNCTIONS DEFINITION
source(file.path("C:","Dropbox","Software","Scripts","r","functions_imgProcessing.R", fsep = .Platform$file.sep))


## Set working directory for the file list at the end

### INPUTS
panoF <- choose.files(caption = "Selecciona el archivo de autopano",filters = matrix(c("pano", "*.pano")),
                      index = nrow(Filters)) # Choose the autopano *.pano file that is using the images of interest

### SCRIPT

list <- separate_img_in_folder_from_pano_file(panoF)
##Save list to disk
write.csv(list,"list.csv")
