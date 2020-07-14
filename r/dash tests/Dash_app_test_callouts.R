library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)

app <- Dash$new(external_stylesheets = "https://codepen.io/chriddyp/pen/bWLwgP.css")

df <- read.csv(
  file = "https://raw.githubusercontent.com/plotly/datasets/master/gapminderDataFiveYear.csv",
  stringsAsFactor=FALSE,
  check.names=FALSE
)

continents <- unique(df$continent)
years <- unique(df$year)

app$layout(
  htmlDiv(
    list(
      dccGraph(id="graph-with-slider"),
      dccSlider(
        id ="year-slider",
        min = 0,
        max = lenght(years) - 1,
        marks = years,
        Value = 0
      )
      
    )
  )
)

app$callback(
  output = list(id = "graph-with-slider",property = "figure"),
  params = list(input(id="year-slider",property = "value")),
  
  function(selected_year_index){
    selected_year <- which(df$year == years[selected_year_index+1])
    
    traces <- lapply(continents,
                 function(cont){
                   selected_continent <- which(df$continent == cont)
                   df_sub <- df[itersect(selected_year)]
                 }
    )
  }
)

app$run_server()