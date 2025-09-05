#### An Introduction to Geographic Data Formatting ####



setwd("/Geospatial_Analysis/R_spatial_codes/part5")

# Install and load the necessary packages.

# install.packages("tidyverse")
# install.packages("terra")
# install.packages("tidyterra")
# install.packages("ggspatial")
# install.packages("ggthemes")
# install.packages("leaflet")
# # install.packages("viridis")

library(tidyverse)
library(terra)
library(tidyterra)
library(ggspatial) 
library(ggthemes)
library(leaflet)
library(viridis)

# Coordinate Reference System (CRS): defines how the locations of an 
# object are represented in a dataset. 

# When working with multiple datasets, their coordinate reference systems (CRS) 
# MUST match.  

# You can convert datasets between different CRSs as needed.  

# Many functions will only give a warning if CRSs are different, so it's 
# your responsibility to perform the necessary conversions.  

# Some functions may automatically handle CRS conversions, but others might 
# fail silently or produce incorrect results.  

# To avoid errors or misleading outputs, always ensure all datasets share 
# the same CRS before performing any analyses. 

states <- vect("/Geospatial_Analysis/R_spatial_codes/Part1/StateBoundaries") 

cities_csv <- read_csv("/Geospatial_Analysis/R_spatial_codes/Part1/cities.csv")
cities <- vect(cities_csv,geom = c("Longitude","Latitude"),crs = "epsg:4326")

# After you read in a vector object, you can see what it's 
# coordinate reference system is by two ways.

# 1. Simply print the vector object and look where it says `coord. ref. :`

print(states)

# 2. Use the `crs` function to extract the coordinate reference system.

crs(states)

# And then compared for equivalency with another layer:

crs(states) == crs(cities)

# Because they are different, we must convert the layers to the same coordinate reference system.  
# We can do that with the `project` function, which is very easy to use. 
# There are two primary ways to use the project function. 

# 1. Supply it directly with the coordinate reference system of another object. 

cities_projected <- project(cities,crs(states))

crs(states) == crs(cities_projected)

# 2. Provide the Well-Known ID (WKID) of the coordinate reference system (CRS).

# The WKID is usually found in the metadata of a dataset, or it can be searched online.
# Below are some of the most commonly used WKIDs:

# - 4326 (WGS 1984): Used globally; common for worldwide datasets.
# - 4269 (NAD 1983): Often used in U.S. datasets, especially from government sources.

# UTM-based systems are better for distance calculations and are commonly used for
# state- or regional-level data. Each UTM zone has its own WKID. For Ohio, two zones apply:
# - 26916 (NAD 1983 UTM Zone 16N)
# - 26917 (NAD 1983 UTM Zone 17N)

# To project a geographic object using a WKID, do this:

cities_projected_WKID <- project(cities,"epsg:4326")

# epsg stands for European Petroleum Survey Group who maintain the WKID database. 

crs(states) == crs(cities_projected_WKID)

# Still false!  Why could this be?

print(crs(states))
print(crs(cities_projected_WKID))

# Even though two layers may represent the same coordinate reference system (CRS), 
# the formatting of the CRS information can sometimes differ slightly. 
# In practice, they will still align correctly, but it’s good practice 
# to ensure that the CRS definitions match exactly before using them together.

states_projected <- project(states,"epsg:4326")

crs(states_projected) == crs(cities_projected_WKID)

# When working with a raster and a vector layer that use different coordinate 
# reference systems (CRS), you should ALWAYS reproject the vector dataset 
# to match the CRS of the raster. This ensures proper alignment and accurate analysis.

# Common geographic data formats:
# One of the simplest and most widely used formats is point coordinates. 
# These are easy to import into R—and you’ve already practiced doing this!


cities_csv <- read_csv("/Geospatial_Analysis/R_spatial_codes/Part1/cities.csv")
cities <- terra::vect(cities_csv,geom = c("Longitude","Latitude"),crs = "epsg:4326")

ggplot() + geom_spatvector(data = cities)

# Make sure that you don't mix up longitude and latitude, or else your map will look incorrect! 

cities_incorrect <- terra::vect(cities_csv,geom = c("Latitude","Longitude"),crs = "epsg:4326")

ggplot() + geom_spatvector(data = cities_incorrect)

# Also, make sure that you specify the correct coordinate reference system. 

cities_incorrect <- terra::vect(cities_csv,geom = c("Longitude","Latitude"),crs = "epsg:3857")

ggplot() + geom_spatvector(data = cities_incorrect)



# Another very common format for geographic data is the shapefile (.shp).  
# This format is also straightforward to use in R—and you’ve already worked with it!


ecoregions <- vect("/Geospatial_Analysis/R_spatial_codes/part5/reg5_eco_l3/reg5_eco_l3.shp") 

ggplot() + geom_spatvector(data = ecoregions,aes(fill = US_L3NAME)) 

# In the folder where a shapefile (.shp) is stored, you’ll notice many other files.  
# All of these files are required, but in R you only need to read in the .shp file.  
# The other files must remain in the same folder as the .shp file.  

# Often, a .prj file is included, which stores the coordinate reference system (CRS).  
# If a .prj file is missing, you will need to manually identify the CRS of the shapefile.

ecoregions <- vect("/Geospatial_Analysis/R_spatial_codes/part5/reg5_eco_l3/reg5_eco_l3.shp",crs = "ESRI:102039") 


# A new geographic data format is the geodatabase (.gdb). 

# This geodatabase contains boundaries of river basins within the 
# Ohio River Basin (what was used to make the PowerPoint map):


river_basins<- vect("D:/Geospatial_Analysis/R_spatial_codes/part5/WBD_05_HU2_GDB/WBD_05_HU2_GDB.gdb")


ggplot() + geom_spatvector(data = river_basins)

# Why is nothing being plotted?  

# Geodatabases (.gdb) can store multiple geographic layers (feature classes).  
# If you try to load the entire geodatabase without specifying a layer, 
# nothing will be plotted.  

# To import a specific layer from a geodatabase, you must explicitly name it 
# in your code (e.g., vect("path/to.gdb", layer = "layer_name")).  


river_basins <- vect("D:/Geospatial_Analysis/R_spatial_codes/part5/WBD_05_HU2_GDB/WBD_05_HU2_GDB.gdb",layer = "WBDHU8")
river_basins
ggplot() + geom_spatvector(data = river_basins)


################################

# Common vector data formats  

# The most common formats for vector geographic data include shapefiles (.shp), 
# GeoJSON, KML, and others.  
# Many other formats exist, but most can be imported into R using the `vect()` function.  


# Common raster data formats  

# Raster datasets come in various formats, such as .tif (GeoTIFF) or .asc (ASCII raster), 
# but there are many others.  
# All of these can be read into R using the methods we have already learned.  

precipitation <- rast("D:/Geospatial_Analysis/R_spatial_codes/Part4/PRISM_tmean_30yr_normal_4kmM5_annual_asc/PRISM_tmean_30yr_normal_4kmM5_annual_asc.asc")
ggplot() + geom_spatraster(data = precipitation)

#########

# Exporting vector and raster datasets

# Instead of importing data into R, you can export your work as a file. 
# This is useful for sharing data with others or saving it for later use.  

# The process is straightforward using the `writeVector()` function for vector data
# and the `writeRaster()` function for raster data.


ohio_boundary <- vect("D:/Geospatial_Analysis/R_spatial_codes/part5/OhioBoundary/OhioBoundary.shp")

ohio_precipitation_cropped <- crop(precipitation,ohio_boundary)

ohio_precipitation_masked <- terra::mask(ohio_precipitation_cropped,ohio_boundary)

ggplot() + geom_spatraster(data = ohio_precipitation_masked) + 
  
  geom_spatvector(data = ohio_boundary,fill = NA)

# The function only requires two inputs: the geographic object 
# and the destination path for the output.



# NOTE: You should always include the file extension within the path. 


writeVector(ohio_boundary,"D:/Geospatial_Analysis/R_spatial_codes/part5/Output/ohio_boundary.shp")

writeRaster(ohio_precipitation_masked,"D:/Geospatial_Analysis/R_spatial_codes/part5/Output/ohio_precipitation.tif")

# Now trying to export the geographic objects again. 

writeVector(ohio_boundary,"D:/Geospatial_Analysis/R_spatial_codes/part5/Output/ohio_boundary.shp")

writeRaster(ohio_precipitation_masked,"D:/Geospatial_Analysis/R_spatial_codes/part5/Output/ohio_precipitation.tif")

# If the file already exists, you will see an error like:
# "Error: (writeVector/raster) file exists. Use 'overwrite=TRUE' to overwrite it."

# To overwrite an existing file, include the argument 'overwrite=TRUE'.

# In some cases, you may not want to allow overwriting. 
# Whether or not to overwrite depends on your needs and the situation.

writeVector(ohio_boundary,"D:/Geospatial_Analysis/R_spatial_codes/part5/Output/ohio_boundary.shp",overwrite = TRUE)

writeRaster(ohio_precipitation_masked,"D:/Geospatial_Analysis/R_spatial_codes/part5/Output/ohio_precipitation.tif",overwrite = TRUE)


# learnt about vector raster data import
# overwriting the file
# change projection
# import and plot vector and raster data