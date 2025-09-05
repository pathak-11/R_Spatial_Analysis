### Manipulating Spatial Data in R 


setwd("/Geospatial_Analysis/R_spatial_codes/Part2")

# Install and load the necessary packages.

# install.packages("tidyverse")
# install.packages("terra")
# install.packages("tidyterra")

library(tidyverse)
library(terra)
library(tidyterra)

# Manipulating Spatial Data #

# With the TidyTerra package, we can manipulate spatial data with 
#functions from the Tidyverse.

# Functions we will learn:

  # filter
  # mutate
  # select
  # left_join

##############################################################################

# Filter: Filtering data to include or not include observations 
#that meet certain criteria.

# Full dataset will create a map with all 50 states.

states <- vect("/Geospatial_Analysis/R_spatial_codes/Part2/AllStateBoundaries") 

ggplot() + geom_spatvector(data = states) 

# But what if we want to only map a subset of the states? #filter

states_filtered <- filter(states,Name == "Georgia") 

ggplot() + geom_spatvector(data = states_filtered)


# Or states without a subset of states?

states_filtered <- filter(states,Name != "Texas")

ggplot() + geom_spatvector(data = states_filtered)


# To include multiple states on our map:  # in- checks val if present

states_filtered <- filter(states,Name %in% c("Oregon","Washington","California","Nevada"))

ggplot() + geom_spatvector(data = states_filtered) 


# To exclude multiple states from our map:

states_filtered <- filter(states,!(Name %in% c("Alaska","Hawaii")))

ggplot() + geom_spatvector(data = states_filtered)


# To include only states from the map based on a specific criteria, 
# such as states greater than 100,000 square miles in area.

states_filtered <- filter(states,`LandArea` > 100000)

ggplot() + geom_spatvector(data = states_filtered)


# Or states less than or equal to 5,000 square miles in area.

states_filtered <- filter(states,`LandArea` <= 5000)

ggplot() + geom_spatvector(data = states_filtered)


# Make a map of your home state displayed with your favorite color.

home_state <- filter(states, Name == "Ohio")

ggplot() +
  geom_spatvector(data = home_state, fill = "pink", color = "white") +
  theme_minimal() +
  labs(title = "Ohio")


# Mutate: Creates a new column with a specific calculation performed

# lepidopteraRecordCount contains the number of lepidoptera records 
# recorded on GBIF for each Ohio county in 2023.

lepidopteraRecordCount <- vect("/Geospatial_Analysis/R_spatial_codes/Part2/NumberOfLepidopteraRecords_2023")

ggplot() + geom_spatvector(data = lepidopteraRecordCount,aes(fill = Records))

# What might be an issue with this data?

# How can we fix it?

lepidopteraRecordCount_mutated <- mutate(lepidopteraRecordCount,RecordsPer1000People = Records/(Population/1000))


ggplot() + geom_spatvector(data = lepidopteraRecordCount_mutated,aes(fill = RecordsPer1000People))

# Select: Selects or unselects specific columns from a vector object. 
# Very useful for organization.


# might not want to keep all columns from our lepidoptera vector object.

print(lepidopteraRecordCount_mutated)

# To select columns from a vector object

lepidopteraRecordCount_selected <- select(lepidopteraRecordCount_mutated,CountyName,RecordsPer1000People)
  
print(lepidopteraRecordCount_selected)

# Or: 

# To unselect a column from a vector object

lepidopteraRecordCount_selected <- select(lepidopteraRecordCount_mutated,-Records)
  
print(lepidopteraRecordCount_selected)

# Select can also be used to reorder a vector object's columns.

lepidopteraRecordCount_selected <- select(lepidopteraRecordCount_mutated,RecordsPer1000People,Population,CountyName) 
  
print(lepidopteraRecordCount_selected)

# left_join: Combines two different data objects together based on a common variable.

# This is a csv file that contains the number of unique species in a taxonomic group for each state.

counts <- read_csv("/Geospatial_Analysis/R_spatial_codes/Part2/StateSpeciesCounts.csv")

# But it does not have any geographic information!

# Let's combine it with our states vector object so that we can make a map with it.

print(states)
print(counts)

statesWithCounts <- left_join(states,counts,by = c("Name" = "States"))

# Take a look at the structure of statesWithCounts

print(statesWithCounts)

# This will list all of the column names of a geographic data object. 

names(statesWithCounts)

# We can now use statesWithCounts to create a choropleth map.

ggplot() + geom_spatvector(data = statesWithCounts,aes(fill = `Freshwater Mussels`),color = "black",linewidth = 1) + 
  
  scale_fill_steps(low = "white",high = "red",n.breaks = 10)





