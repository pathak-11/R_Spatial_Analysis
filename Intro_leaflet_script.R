### A Very Basic Introduction to R. ###

# Your working directory is where your files are stored. You must tell R where to look on your computer. 

#  it is the path to your files.

# Change your working directory to the folder that contains files of interest:

setwd("/Geospatial_Analysis/KP_geospatialday1&2")
setwd("/Geospatial_Analysis/KP_geospatialday1&2")

# To make sure that your working directory was correctly changed:

getwd()

# And to see which folders and files are in your working directory:

list.files()

# You should always make sure that your working directory is correctly set before proceeding with any of these scripts.

# Next, we need to install and load all of the necessary R packages.

# Think of packages as a collection of tools to use for R.

# Normally, you would need to install packages, but we already did this for you!

# But we still need to tell R to load them. We must do this everytime we begin a new R session!

# Install and load the necessary libraries

#install.packages("tidyverse")

install.packages("tidyverse")
install.packages("terra")
install.packages("tidyterra")


library(tidyverse)
library(terra)
library(tidyterra)

### Introduction to Vector Data: points, lines, and polygons ###

## Points ##

# Terra's vect function reads geographic data and converts it to a SpatVector object, which can be used in R.

# This is a csv file of the largest 150 cities in the US and their coordinates.

cities_csv <- read.csv("/Geospatial_Analysis/R_spatial_codes/Part1/cities.csv")

cities <- vect(cities_csv,geom = c("Longitude","Latitude"),crs = "epsg:4326")

# This can then be plotted using ggplot's structure. 
library(ggplot2)

ggplot() + geom_spatvector(data = cities)

# Various aesthetics of the points can be changed.

# Such as color,

ggplot() + geom_spatvector(data = cities,color = "red")

# size,

ggplot() + geom_spatvector(data = cities,size = 5)

# or shape.

ggplot() + geom_spatvector(data = cities,shape = 3)

# Multiple aesthetics can be changed at once. 

ggplot() + geom_spatvector(data = cities,color = "blue",shape = 15,size = 3)

# Aesthetics can be linked to a specific variable of the data. 

ggplot() + geom_spatvector(data = cities,aes(size = Population))

# Aesthetics that are linked to a variable must be inside of the `aes` argument. If not, an error will occur.

ggplot() + geom_spatvector(data = cities,size = Population)

# Vice versa, aesthetics that are not linked to a variable cannot be inside of the `aes` argument.

ggplot() + geom_spatvector(data = cities,aes(color = "green"))

## Lines ##

# Again we start by converting geographic data into a SpatVector object.

roads <- vect("/Geospatial_Analysis/R_spatial_codes/Part1/Interstates")

ggplot() + geom_spatvector(data = roads)

# Line aesthetics can also be changed. A few relevant options are

# color,

ggplot() + geom_spatvector(data = roads,color = "red")

# linewidth,

ggplot() + geom_spatvector(data = roads,linewidth = 1.5)

# or linetype.

ggplot() + geom_spatvector(data = roads,linetype = 3)

# Multiple features can be plotted together. For example,

ggplot() + geom_spatvector(data = cities,color = "black") + 
  
  geom_spatvector(data = roads,color = "grey")

# But order of the features matters! Fix the above code.
  
# Each unique feature will have its own settings that will need to be set. 

## Polygons ##

# The final type of vector data are polygons.

states <- vect("/Geospatial_Analysis/R_spatial_codes/Part1/StateBoundaries") 

ggplot() + geom_spatvector(data = states)

# Polygon aesthetics can also be changed. A few relevant options are

# fill (the color of inside the polygon),

ggplot() + geom_spatvector(data = states,fill = "blue")

# (to make transparent polygons, set fill to NA)

ggplot() + geom_spatvector(data = states,fill = NA)

# color (the color of the polygon's border),

ggplot() + geom_spatvector(data = states,color = "purple")

# and linewidth (the width of the polygon's border).

ggplot() + geom_spatvector(data = states,linewidth = 2)

# And again, a polygon's aesthetics can be linked to one of the data's variables.

ggplot() + geom_spatvector(data = states,linewidth = .5,color = "black",fill = Name) 

# What might be wrong? Fix the above code.

# now put all 3 of our features together to create our map.

ggplot() + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities) + 
  
  geom_spatvector(data = states)

# What might be wrong? Fix the above code?


##

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities)

##

install.packages("leaflet")
library(leaflet)

# Leaflet: Creating interactive maps in R

leaflet() %>%
  
  addTiles() %>%
  
  addPolygons(data = states,color = "black",fillColor = "white",fillOpacity = 1,opacity = 1,weight = 1) %>%
  
  addPolylines(data = roads,color = "darkgrey",opacity = 1,weight = 1) %>%
  
  addMarkers(data = cities,popup = ~paste0(City_Name,", ",State_Name))



#### rectangles 

library(leaflet)

leaflet() |>
  addTiles() |>
  setView(lng = -82.1013, lat = 39.3292, zoom = 13) |>
  addRectangles(
    lng1 = -82.12, lat1 = 39.32,   # southwest corner
    lng2 = -82.08, lat2 = 39.34,   # northeast corner
    fillColor = "blue", fillOpacity = 0.2, color = "darkblue")


##### circles / pop up

# Example circle locations in Athens, 
## Ohio University (college green)
# Two example circle locations around Athens, OH
circles <- data.frame(
  lng = c(-82.1013, -82.0850),   # Longitudes
  lat = c(39.3292, 39.3400)      # Latitudes
)

leaflet() %>%
  addTiles() %>%   # default osm tiles
  setView(lng = -82.1013, lat = 39.3292, zoom = 13) %>% # sets center of the map
  addCircles(
    lng = ~lng, lat = ~lat,
    data = circles,
    radius = 2000, # plots circular radius, 2000 meter
    popup = paste0("Title", "<hr>", "A", "<br>", "B") # pop up circles
  ) %>%
  addCircleMarkers(
    lng = ~lng, lat = ~lat,
    data = circles,
    popup = c("A", "B")
  )

