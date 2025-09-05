#### Part 3: Advanced Mapping in R 


setwd("/Geospatial_Analysis")

# Install and load the necessary packages.
install.packages("ggthemes")
install.packages("ggspatial")

# install.packages("tidyverse")
# install.packages("terra")
# install.packages("tidyterra")
# install.packages("ggspatial")
# install.packages("ggthemes")

library(tidyverse)
library(terra)
library(tidyterra)
library(ggspatial) 
library(ggthemes)

# till now, a basic understanding of how to change the 
# aesthetics of geographic data in R.

# In this part, we are going to build on this, and learn how to 
# add additional features to our maps. 

# The necessary aesthetics of a professional looking map:

# 1. Map Frame
# 2. Map Legend
# 3. Map Title
# 4. Compass
# 5. Scale
# 6. Map Citations
# 7. Authorship
# 8. Inset Map (sometimes)

# Other things to consider:

# 1. Visual hierarchy: Important elements need to be more emphasized than less 
#    important elements.
# 2. Balance of empty space
# 3. Clutter reduction
# 4. Who is your audience?

# Now, how to add some of these features to our map.

# First, reload the data from the last part of the workshop (if needed).

cities_csv <- read_csv("/Geospatial_Analysis/R_spatial_codes/Part1/cities.csv")
cities <- vect(cities_csv,geom = c("Longitude","Latitude"),crs = "epsg:4326")

roads <- vect("/Geospatial_Analysis/R_spatial_codes/Part1/Interstates")

states <- vect("/Geospatial_Analysis/R_spatial_codes/Part1/StateBoundaries") 

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities)

## Title:

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities) +
  
  labs(title = "United States' Major Roads and Cities") +
  
  theme(plot.title=element_text(hjust=.5))

##

## Scale:

# Uses the annotation_scale() function from the ggspatial package.

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities) + 
  
  annotation_scale(unit_category = "imperial")

##

## Compass:

# Uses the annotation_north_arrow() function from the ggspatial package.

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities) + 
  
  annotation_north_arrow(location = "br",style = north_arrow_fancy_orienteering)

##

# Legend

# When you link an aesthetic to a specific variable in the data, a legend will automatically be created.

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities, aes(size = Population)) 

# To change the title of the legend:

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities, aes(size = Population))  + 
  
  labs(size = "City Population")


# To change the position of the legend:

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities, aes(size = Population)) + 
  
  theme(legend.position = "bottom")

# Creating a legend becomes more complicated when an aesthetic 
# is not linked to a specific variable.

# To do so, you must assign the desired name on the legend to the aesthetic. 
#For example,

ggplot() + 
  
  geom_spatvector(data = states, aes(color = "State Boundary"),
                  fill = "white",linewidth = .5) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities)

# And then to set the color, you must:

ggplot() + 
  
  geom_spatvector(data = states, aes(color = "State Boundary"), fill = "white",linewidth = .5) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities) +
  
  scale_color_manual(values = "black") + 
  
  labs(color = "")



# And all 3 elements together:

ggplot() + geom_spatvector(data = states,aes(color = "State Boundary"),fill = "white",linewidth = .5) + 
  
  geom_spatvector(data = roads,aes(color = "Interstate")) +
  
  geom_spatvector(data = cities,aes(color = "City")) + 
  
  scale_color_manual(values = c("State Boundary" = "black","Interstate" = "grey","City" = "black")) + 
  
  labs(color = "")




# Citations and Authorship

# \n is an escape character and will create a new line of text

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities) + 
  
  labs(caption = "\nAuthor: Kamana Pathak\nDate: 7/15/2025") 


# Clutter Reduction:

# The theme_map() function from ggthemes will remove clutter that is not necessary for most maps.

ggplot() + 
  
  geom_spatvector(data = states) + 
  
  geom_spatvector(data = roads) +
  
  geom_spatvector(data = cities) + 
  
  theme_map()

##


############



# Putting it all together

ggplot() + 
  
  geom_spatvector(data = states,aes(color = "State Boundary"),fill = "white",linewidth = .5) + 
  
  geom_spatvector(data = roads,aes(color = "Interstate")) +
  
  geom_spatvector(data = cities,aes(color = "City")) + 
  
  scale_color_manual(values = c("State Boundary" = "black","Interstate" = "grey","City" = "black")) + 
  
  labs(color = "") + 
  
  labs(title = "United States' Major Roads and Cities") + 
  
  annotation_north_arrow(location = "br",style = north_arrow_fancy_orienteering) + 
  
  annotation_scale(unit_category = "imperial") +
  
  theme_map() +
  
  labs(caption = "\nAuthor: Kamana Pathak\nDate: 7/15/2025") +
  
  theme(legend.position = "bottom",plot.title=element_text(hjust=.5)) 
  


# make a park with boundary, lake, roads along the park, boat launc, and campground
#

ParkBoundary <- vect("/Geospatial_Analysis/R_spatial_codes/Part3/ForParkMap/ParkBoundary.shp")
Lake <- vect("/Geospatial_Analysis/R_spatial_codes/Part3/ForParkMap/Lake.shp")
Roads <- vect("/Geospatial_Analysis/R_spatial_codes/Part3/ForParkMap/Roads.shp")
BoatLaunch <- vect("/Geospatial_Analysis/R_spatial_codes/Part3/ForParkMap/BoatLaunch.shp")
Campgrounds <- vect("/Geospatial_Analysis/R_spatial_codes/Part3/ForParkMap/Campgrounds.shp") 

## code goes here! 

ggplot() +
  
  geom_spatvector(data = ParkBoundary, fill = "forestgreen") + 
  
  geom_spatvector(data = Lake, fill = "blue") + 
  
  geom_spatvector(data = Roads) + 
  
  geom_spatvector(data = BoatLaunch, color = "red", size = 2) + 
  
  geom_spatvector(data = Campgrounds, size = 2) 
  
##

