##Script para sacar box plot de los cuadros de 30x30 desde imagen de satélite

#Packages, source
source(file.path("C:","Dropbox","Software","Scripts","r","functions_imgProcessing.R", fsep = .Platform$file.sep))
require(raster)

#Data
sen2img <- raster(chooseTifs()) #load image
sen2img <- sen2img/1000 # Transform to proper scale. divide by 1000
c30x30 <- readOGR(dsn="F:\\Dropbox\\data\\AH\\mapas\\AH_ciclo\\AH_ciclo.gdb", layer="Wheat2020_30x30") #Call the polygons froma GDB
pxls <- extract(sen2img, polygons) #Extract the pixel values from image based on the polygon

##Get the boxplots from the extracted pixel values for each polygon
## Save to a PDF
pdf("WheatCOMPASS_boxplot30x30LAI.pdf")
for (i in 1:length(pxls)) {
  #Generate the boxplot corresponding to each polygon, add the label to which area and field they correspond
  boxplot(pxls[[i]],main=sprintf("Boxplot Polygon %s,Field %s, %s area",
                                 c30x30@data[i,c("Id")], # Get the data from the polygon data table
                                 c30x30@data[i,c("name")], 
                                 c30x30@data[i,c("subarea")]))
}
dev.off()
