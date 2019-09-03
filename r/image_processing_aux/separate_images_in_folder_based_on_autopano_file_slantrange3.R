### Script to separate the files from the thermal imagery that correspond to a specific area, based on the autopano mosaic file.
### The output folder is created based on the name of the autopano file, inside the 
### TODO: implement error catching in the script

####################################################### FUNCTIONS DEFINITION
source(file.path("C:","Dropbox","Software","Scripts","r","functions_imgProcessing.R", fsep = .Platform$file.sep))



### INPUTS
panoF <- choose.files(caption = "Selecciona el archivo de autopano",filters = matrix(c("pano", "*.pano")),
                      index = nrow(Filters)) # Choose the autopano *.pano file that is using the images of interest

### SCRIPT
setwd(dirname(panoF)) #set WD tot he location of the autopano file (that should be in the same directory as the indivitual band images)
get_filenames_from_pano_file_slantrange3(panoF)
