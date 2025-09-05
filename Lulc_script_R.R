##### An Introduction to Raster Data ####



setwd("/Geospatial_Analysis")

# Install and load the necessary packages.

# install.packages("tidyverse")
# install.packages("terra")
# install.packages("tidyterra")
# install.packages("ggspatial")
# install.packages("ggthemes")
# install.packages("leaflet")
# # install.packages("viridis")

install.packages("viridis")


library(tidyverse)
library(terra)
library(tidyterra)
library(ggspatial) 
library(ggthemes)
library(leaflet)
library(viridis)

# So far, focused on vector data, which can be broadly defined 
# as points, lines, and polygons. 

# Another common form of geographic data is raster data. 

# Raster data represents geographic information as a continuous 
# grid of pixels, with each pixel holding a specific value. 

# In R, instead of using `vect` for vectors, we use Terra's `rast` 
# function to create a SpatRaster object for raster data analysis.

precipitation <- rast("Day2_Part1/PRISM_ppt_30yr_normal_4kmM4_annual_asc/PRISM_ppt_30yr_normal_4kmM4_annual_asc.asc")
precipitation <- rast("R_spatial_codes/Part4/PRISM_ppt_30yr_normal_4kmM4_annual_asc/PRISM_ppt_30yr_normal_4kmM4_annual_asc.asc")


# We can then map our raster, using geom_spatraster instead of geom_spatvector

ggplot() + geom_spatraster(data = precipitation)

# Leaflet can also be used to map raster data. Zoom in close to see the structure of raster data!

leaflet() %>%
  
  addTiles() %>%
  
  addRasterImage(precipitation) 

# The color scheme of a raster map can be easily customized.

# We'll use the 'viridis' package, which provides pre-built 
# color palettes suitable for raster data visualization.

# These palettes are color-blind friendly, which is important 
# to consider when creating accessible and effective maps.

ggplot() + geom_spatraster(data = precipitation) +
  
  scale_fill_viridis()

# We want to change raster cells with no values (for example the ocean) to a white color.

ggplot() + geom_spatraster(data = precipitation) +
  
  scale_fill_viridis(na.value = "white")

# There are 8 different color palettes (A-H) in this package. They can be accessed with:

ggplot() + geom_spatraster(data = precipitation) +
  
  scale_fill_viridis(option = "A",na.value = "white")

# The viridis color pallette can be used for binned gradients as well. Use scale_fill_viridis_b

ggplot() + geom_spatraster(data = precipitation) +
  
  scale_fill_viridis_b(option = "E",na.value = "white")

# To make the color scale go the other way:

ggplot() + geom_spatraster(data = precipitation) +
  
  scale_fill_viridis_b(option = "E",na.value = "white", direction = -1)


######

# Vector data and raster data can be mapped together

state_boundaries <- vect("/Geospatial_Analysis/R_spatial_codes/Part4/StateBoundaries") 

ggplot() +
  
  geom_spatvector(data = state_boundaries,fill = NA,color = "black") + 
  
  geom_spatraster(data = precipitation)
  
# But again, the order matters
# The shape boundaries are hidden behind the raster. 

#  fix that!

ggplot() +
  
  geom_spatraster(data = precipitation) + 
  
  geom_spatvector(data = state_boundaries,fill = NA,color = "black")

# Take some time to map and change the color scheme of this elevation raster with state boundaries:

elevation <- rast("/Geospatial_Analysis/R_spatial_codes/Part4/Elevation/Elevation.asc")

## 

ggplot() 

##


###########

### Manipulating Raster Data ###

# The size of each raster cell is defined by its resolution. 

# We can check the resolution of a raster using:
# res(elevation)

# For example, our raster has a resolution of 3662.903 meters 
# in both the x (width) and y (height) directions.

# If we want a raster with a different resolution, we can resample it.

# To resample, we create a temporary raster that mirrors the original 
# in all aspects except for the desired resolution.

# Note: The units of this raster are meters. For instance, 10 kilometers = 10,000 meters.



templateRaster_10kilometers <- rast(ext(elevation), res = 10000, crs = crs(elevation))

elevation_10kilometers <- resample(elevation,templateRaster_10kilometers)

res(elevation_10kilometers)

# For visualization, let's reduce the resolution of precipitation to 100 kilometers.

templateRaster_100kilometers <- rast(ext(elevation), res = 100000, crs = crs(elevation))

elevation_100kilometers <- resample(elevation,templateRaster_100kilometers)

res(elevation_100kilometers)

ggplot() + geom_spatraster(data = elevation_100kilometers)

# IMPORTANT: Do NOT resample a raster to a higher resolution, 
# only to a lower resolution!

# Technically, you can increase resolution, but this introduces 
# interpolated data that may not reflect reality.

# Keep in mind that raster units depend on the coordinate 
# reference system (CRS) of the dataset and may not always be meters.

# We will explain this in more detail in the next section.


##############

# Cropping a Raster

# The 'crop' function allows you to trim a raster to a specific extent 
# defined by another geographic object.

# Think of an extent as a rectangular boundary that surrounds the object 
# you want to focus on.

iowa_boundary <- filter(state_boundaries,NAME == "Iowa")

iowa_extent <- as.polygons(ext(iowa_boundary),crs = crs(iowa_boundary))

# This will plot both the Iowa outline and its extent.

ggplot() + geom_spatvector(data = iowa_extent,fill = "white",color = "black",linewidth = .5) + 
  
  geom_spatvector(data = iowa_boundary,fill = "red")

# The crop function will remove all raster cells that are outside of the extent of the object. 

iowa_precipitation_cropped <- crop(precipitation,iowa_boundary)

ggplot() + geom_spatraster(data = iowa_precipitation_cropped) + 
  
  geom_spatvector(data = iowa_boundary,fill = NA,color = "black",linewidth = .5)


# Masking #

# The mask function will convert all values of a raster outside of an exact outline of another geographic object to 0. #

iowa_precipitation_masked <- terra::mask(precipitation,iowa_boundary)

ggplot() + geom_spatraster(data = iowa_precipitation_masked) + 
  
  geom_spatvector(data = iowa_boundary,fill = NA,color = "black",linewidth = .5)

# But this does not change the extent of the masked object. #

# Because of this, you should crop and then mask an object to avoid this. #

# This will also save on computing time for very large geographic data. #

iowa_precipitation_cropped <- crop(precipitation,iowa_boundary)

iowa_precipitation_masked <- terra::mask(iowa_precipitation_cropped,iowa_boundary)

ggplot() + geom_spatraster(data = iowa_precipitation_masked) + 
  
  scale_fill_continuous(na.value = "white") + 
  
  geom_spatvector(data = iowa_boundary,fill = NA,color = "black",linewidth = .5)


#########################################################

# to create a map, follow these steps: 

##

temperature <- rast("/Geospatial_Analysis/R_spatial_codes/Part4/PRISM_tmean_30yr_normal_4kmM5_annual_asc/PRISM_tmean_30yr_normal_4kmM5_annual_asc.asc")

### Steps ###

# First, you will need to filter the state_boundaries dataset to select states of interest.

#states_filtered <- filter()

# Second, you will need to crop and mask the temperature raster using the selected state boundary.

#states_cropped <- crop()

#states_cropped_and_masked <- mask()

# Third, you will need to create a map. 





#########################################################

#  Create a land use map for a county in Ohio of your choosing. 

# You should use this following color palette when making your map. 

# You can use this by including: scale_fill_manual(values = nlcd_color_palette)

# This color palette gives colors to land cover classifications that are easy to understand. 

# Blue for water, green for trees, etc.. 

land_color_palette <- c("Temperate or Subpolar Needleaf Forest" = "#173B0B",
                        "Temperate or Subpolar Broadleaf Deciduous Forest" = "#418A46",
                        "Mixed Forest" = "#617436",
                        "Temperate or Subpolar Shrubland" = "#AD8C43",
                        "Temperate or Subpolar Shrubland" = "#DFD093",
                        "Wetland" = "#78A18B",
                        "Cropland" = "#DEB171",
                        "Barren Land" = "#A9ABAE",
                        "Urban and Built-up" = "#C93731",
                        "Water" = "#546F9F")

# final map should include the land use raster and the county outline. 


##

counties <- vect("Day2_Part1/CountyBoundaries/CountyBoundaries.shp") %>% filter(State == "Ohio")
counties <- vect("/Geospatial_Analysis/R_spatial_codes/Part4/CountyBoundaries/CountyBoundaries.shp") %>% filter(State == "Ohio")

land_use_raster <- rast("/Geospatial_Analysis/R_spatial_codes/Part4/OhioLandCover.tif") 

# Here is what the full land use raster looks like. #
ggplot() + geom_spatraster(data = land_use_raster) + 
  
  scale_fill_manual(values = land_color_palette, na.value = "white")

### Steps ###

# 1. Select your county of interest. You may need to filter by county name AND 
# state name (if multiple states have same names for counties).

library(dplyr)

county_boundary <- counties %>%
  filter(Name == "Athens" & Name == "Ohio")

# 2. Crop and mask the land_use_raster with your selected county boundary.
 # county_cropped <- crop(land_use_raster, county_boundary)
 # county_cropped_and_masked <- mask(county_cropped, county_boundary)

# 3. Create your map. 

ggplot() + geom_spatraster() + 
  
  geom_spat_vector() +
  
  scale_fill_manual(values = land_color_palette, na.value = "white")


## learnt lulc, piping, mask, crop

