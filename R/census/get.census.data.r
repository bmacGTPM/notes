## get.census.data.r
## Script retrieves, cleans and saves Census data to rds file 
## (GEOID, Median Income, Total Population, Total Age, etc)

## See these for the variable codes:
# Census API: https://www.census.gov/data/developers/data-sets.html
# ACS:        https://www.census.gov/data/developers/data-sets/acs-1year.html
# Decennial:  https://www.census.gov/data/developers/data-sets/decennial-census.html

# commenting this b/c it installs package `units` which causes Github Actions to fail
#library(tidycensus) ## ******************uncomment this**************
library(tidyverse)
year=2019


## You need a census API key. 
## See https://api.census.gov/data/key_signup.html
## Once you get it, you can store it using 
## census_api_key('yourAPIkeyHere', install=TRUE)
## That only needs to be done once (hopefully) 
## and it will be stored in your .Renviron file. 
## Then you can use this  
readRenviron("~/.Renviron") 

## all
us <- unique(fips_codes$state)[1] ## change to 1:51 for all states and DC

## for ACS
vars <- c(# Total, Male, Female
                  "B01001_001", "B01001_002", "B01001_026", 
                  
                  # Median age, Male age, Female age
                  "B01002_001", "B01002_002", "B01002_003", 
                  
                  # Race: White, Black, Native, Asian, Pacific, Other, 2+
                  "B02001_002", "B02001_003", "B02001_004", 
                  "B02001_005", "B02001_006", "B02001_007", "B02001_008", 
              
                  # white non-hispanic, hispanic, white hisp, black hisp
                  "B03002_003", "B03002_012", "B03002_013", 'B03002_014',
               
                  # Household income ranges: 
                  # <10k, 10000-14999, ... , 150000-199999, >200k 
                  "B19001_001", "B19001_002", "B19001_003", "B19001_004",
                  "B19001_005", "B19001_006", "B19001_007", "B19001_008",
                  "B19001_009", "B19001_010", "B19001_011", "B19001_012",
                  "B19001_013", "B19001_014", "B19001_015", "B19001_016",
                  "B19001_017",
                  
                  "B19013_001", # Median Household Income
                  "B25077_001"  # Median Housing Value
                  ) 

# fails with geometry = TRUE, so removing.  
# We get tract info from elsewhere anyway.
d = get_acs(geography = "tract",
            variables = vars, 
            state = us, 
            year = year) 

# census_data <- get_decennial(geography = "tract", 
#                              variables = vars, 
#                              state = 'CT', 
#                              year=2020) 

dd <- d %>%
  mutate(tract      = gsub(',.+|Census Tract ', '', NAME),
         county     = gsub(', [A-z]+$|'       , '', NAME), 
         county     = gsub('^.+, '            , '', county),
         state.full = gsub('.+, '             , '', NAME)) %>%
  select(GEOID, tract, county, state.full, variable, estimate) %>%
  pivot_wider(names_from  = variable, 
              values_from = estimate) %>%
  rename(                'pop' = 'B01001_001', ## total population
                        'male' = 'B01001_002', ## sex
                      'female' = 'B01001_026',
                         'age' = 'B01002_001', ## age
                    'male.age' = 'B01002_002',
                  'female.age' = 'B01002_003',
                  
                       'white' = 'B02001_002', ## race
                       'black' = 'B02001_003',
              'indian.alaskan' = 'B02001_004',
                       'asian' = 'B02001_005',
                     'pacific' = 'B02001_006',
                       'other' = 'B02001_007',
                 'two.or.more' = 'B02001_008',
              'white.not.hisp' = 'B03002_003',
                        'hisp' = 'B03002_012',
                  'white.hisp' = 'B03002_013',
                  'black.hisp' = 'B03002_014',
                  'households' = 'B19001_001',
         
                   'i10orless' = 'B19001_002', ## income
                     'i10to14' = 'B19001_003',
                     'i15to19' = 'B19001_004',
                     'i20to24' = 'B19001_005',
                     'i25to29' = 'B19001_006',
                     'i30to34' = 'B19001_007',
                     'i35to39' = 'B19001_008',
                     'i40to44' = 'B19001_009',
                     'i45to49' = 'B19001_010',
                     'i50to59' = 'B19001_011',
                     'i60to74' = 'B19001_012',
                     'i75to99' = 'B19001_013',
                    'i100to124'= 'B19001_014',
                    'i125to149'= 'B19001_015',
                    'i150to199'= 'B19001_016',
                   'i200ormore'= 'B19001_017',
                   'hh.income' = 'B19013_001',
                 'house.value' = 'B25077_001'#,
             # 'TotalChildren' = 'B05009_001' # doesn't exist for 2009
         ) %>%
  as.data.frame()
head(dd)

## census
filename = paste0('rawdata/census', year, '.rds')
saveRDS(dd, file = filename)
