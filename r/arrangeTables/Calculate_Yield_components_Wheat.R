####Calculate yield components from raw measurements Wheat CIMMYT 2020, Nutrients department
#### Column Variable names in the input table should be as follows
## WG : Weight of fresh grain subsample to calculate moisture from plot (g)
## DG : Weight of dry grain subsample to calculate moisture from plot (g)
## HA : Harvested area (m2)
## W400 : Weight of 400 grains (g)
## BIO50D : Dry Weight of spikes sample in area: 0.5m x 0.8m (g)
## GRANO50 : Weight of dry grain from spikes sample (g)
## PM : weight of the bag for the spike sample (g)
## PMG : weight of the bag for the grain (g)
## ANTHESIS	: Days from sowing to Z65
## MATURITY : Days from sowing to Z87
## HT : Hectolitic weight (g/l)
## PB : Kernels with yellow berry - starch instead of protein (n every 400)
## PN : Kernels with black tip fungus (n every 400)
## KB : Kernels with Karnal bunt (n every 400)
## COUNT : plant count in in area: 0.5m x 0.8m
## HEIGHT : Average Height of plants in plot (cm)

##Import raw data from file
#setwd("C:/temp/")
f <- choose.files()
basename <- basename(tools::file_path_sans_ext(f))
d <- read.csv(f) #open csv file

## Function to calculate the yield component variables
YIELDC<- function(d){
  #Initialize new dataframe to save calculated variables
  y <- data.frame(plot = d[,1])# Get the column 1 as ID, the "plot" identifier
  #y$hi <-  d$GRANO50 /(d$BIO50D- d$PM) ## Harvest index
  #y$yield0 <- (((d$DG/d$WG)*(d$GRANO - d$PMG)) + d$GRANO50)/d$HA ## Yield at 0% moisture (g/m2)
  y$yield12 <- (((d$GRANO - d$PMG + d$GRANO50)*10)/d$HA)*((100-(((d$WG-d$DG)/d$WG)*100))/(100-12)) ## Yield 12% (kg/ha)
  y$biomass <- (y$yield0/y$hi)*10 ## Dry biomass (kg/ha)
  y$spikesm2 <- (y$biomass/ ((d$BIO50D- d$PM) /100))/10 ## Spikes per square meter [Divide by 50 because they are 50 spikes?]
  y$w1000 <- d$W400*1000/400 ## Weight of 1000 kernels (g)
  y$grainsm2 <- (y$yield0/y$w1000)*1000 ## Grains per square meter
  #y$grainss <- y$grainsm2/y$spikesm2 ## Grains per spike
  y$anthesis <- d$ANTHESIS
  y$maturity <- d$MATURITY
  #0y$ht <- d$HT
  y$pb <- d$PB*100/400 ## Yellow berry in kernels (%)
  y$pn <- d$PN*100/400 ## Black point in kernels (%)
  #y$kb <- d$KB*100/400	## Karnal bunt in kernels (%)
  y$count <- d$COUNT
  y$height <- d$HEIGHT
  
  return (y) ## Return the calculated variables
}

## Calculate yield components 
yieldC <- YIELDC(d)

## Average repetitions (first char of the plot ID)
## Remove the Rep ID to have the treatments ID
yieldC_avg <- yieldC
yieldC_avg[,1] <- substring(yieldC_avg[,1], 2)  ## keep from the 2nd char on of the ID column
yieldC_avg <- aggregate(. ~ plot, yieldC_avg, mean) # Average table by treatment(plot) ID

##Save to disk
write.csv(yieldC_avg,paste0(basename,"_Yield_avg.csv"), row.names = FALSE)
write.csv(yieldC,paste0(basename,"_Yield.csv"), row.names = FALSE)