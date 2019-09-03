#CÓDIGO PARA GRAFICAR Y CORRELACIONES ROTOPIXELS

source("C:/Dropbox/Software/Scripts/r/ROTOPIXELS/arrangeDBFTablestoExcel_rotopixels.R")

################################################################
###################### SCRIPT ##########################################
#################   Check these inputs#########################
#wd<-("C:\\Users\\CIMMYT\\Documents\\ArcGIS")
wd <- "I:\\rotopixels2018\\1_INDICES\\0_estadisticas"
getwd()

#read tables
## Rread extra data that will be merged to the VI data, needs to have the "id" field or will fail the script
##read metadatos
m <- read.csv("metadatos_rotopixels.csv")
##read n content table, needs to have the "boleta" field. lab table
lab <- read.csv("DATOS_DEL_LABORATORIO.csv",stringsAsFactors=FALSE)
##Get table
table <- getTable(wd,m,lab)

##Separate in columns the VIs for each date -- Wide table format
#atributos por fecha en columnas added
table_complete <- separateInColumnsbyTheVIs(table,'MEAN')
table_complete_norm <- separateInColumnsbyTheVIs(table,'MEAN_NORM_DIAS')

####################Grafica con R cuadrado########################
#Agregar columna de "num_medicion" a "table_complete"#
#Esto para poder cambiar de simbolo/color cada fecha#
#Tambien investigar como colocar linea a cada grupo de datos#

x <- 1:100 #Investigar este calculo de abajo. 
y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
my.data <- data.frame(x = x, y = y,
                      group = c("A", "B"),
                      y2 = y * c(0.5,2),
                      w = sqrt(x))
# Dar nombre a la formula
formula <- y ~ poly(x, 3, raw = TRUE)
#ggplot 
ggplot(table[table$VI=="NDVI" & table$num_medicion==3,], aes(MEAN, N_PERCENT)) + 
   geom_point(color="red") + geom_smooth(method = lm, se = FALSE)+ 
   stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+stat_fit_glance(method = 'lm',
     method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", 
     signif(..p.value.., digits = 4), sep = "")),
     label.x.npc = 'right', label.y.npc = 0.35, size = 3)+
  xlab("NDVI fecha 3") + ylab("PROTEIN") +
  ggtitle("PROTEIN-VI CORRELATION ") 

#Graficas con indices estandarizados
x <- 1:100 #Investigar este calculo de abajo. 
y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
my.data <- data.frame(x = x, y = y,
                      group = c("A", "B"),
                      y2 = y * c(0.5,2),
                      w = sqrt(x))
# Dar nombre a la formula
formula <- y ~ poly(x, 3, raw = TRUE)
#ggplot 
ggplot(table[table$VI=="NDVI" & table$num_medicion==3,], aes(MEAN_NORM_DIAS, N_PERCENT)) + 
  geom_point((aes(color= factor(Campos))))+ 
  stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+xlab("NDVI VALUE (3)") + ylab("PROTEIN") +
  ggtitle("PROTEIN-VI CORRELATION ") 


#Grafica sin estandarizar con distincion de los campos.Se grafica por cada indice en determinada toma
x <- 1:100 #Investigar este calculo de abajo. 
y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
my.data <- data.frame(x = x, y = y,
                      group = c("A", "B"),
                      y2 = y * c(0.5,2),
                      w = sqrt(x))
# Dar nombre a la formula
formula <- y ~ poly(x, 3, raw = TRUE)
#ggplot 
ggplot(table[table$VI=="NDVI" & table$num_medicion==3,], aes(MEAN, N_PERCENT,shape=factor(Campos), fill=factor(Campos), col=factor(Campos))) + 
  geom_point(size=2)+ stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+xlab("NDVI fecha3") + ylab("PROTEIN") +
  ggtitle("PROTEIN-VI CORRELATION ")+scale_shape_manual(values=rep(c(21:25), times=8))








##############R cuadrado de un indice con la 3 fechas de diferente color################
###https://ggplot2.tidyverse.org/reference/scale_manual.html###
x <- 1:100 #Investigar este calculo de abajo. 
y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
my.data <- data.frame(x = x, y = y,
                      group = c("A", "B"),
                      y2 = y * c(0.5,2),
                      w = sqrt(x))
# Dar nombre a la formula
formula <- y ~ poly(x, 3, raw = TRUE)
#ggplot usando table y filtrando por fila
ggplot(table[table$VI=="NDVI",], aes(MEAN, N_PERCENT)) + 
  geom_point((aes(colour = factor(num_medicion)))) + 
  scale_color_manual(values=c("blue","green","red"))+
  geom_smooth(method = lm, se = TRUE)+ 
  stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+ 
  xlab("NDVI") + ylab("PROTEIN") +
  ggtitle("PROTEIN-VI CORRELATION ") 

#check elimination of outliers

#Ejemplo para filtrar
table[table$num_medicion==2,]
table[table$VI=="NDVI" & table$num_medicion==2,] #filas,columnas
table[table$VI=="R675" | table$VI=="NDVI",]


#Graficas separadas con r2 y p-value.Me dijo el doc que preferia por separado.
x <- 1:100 #Investigar este calculo de abajo. 
y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
my.data <- data.frame(x = x, y = y,
                      group = c("A", "B"),
                      y2 = y * c(0.5,2),
                      w = sqrt(x))
ggplot(table[table$VI=="NDVI",], aes(MEAN, N_PERCENT, colour = factor(num_medicion))) +
  geom_point() + facet_grid(. ~ num_medicion, scales = "free")+geom_smooth(method = lm, se = FALSE)+ 
  stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+ stat_fit_glance(method = 'lm',
  method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
  label.x.npc = 'right', label.y.npc = 0.35, size = 3)+
  xlab("NDVI") + ylab("PROTEIN") + ggtitle("PROTEIN-VI CORRELATION ") 

