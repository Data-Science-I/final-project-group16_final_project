# Load required libraries
library(tidycensus)
library(tidyverse)

# Set Census API Key
census_api_key("e233dd6c7bc9c7a8a8e6cd16ff8e0d295d189dbf", install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron") # Reload API key

# Load all variables for ACS 5-year data in 2021
acs_vars <- load_variables(year = 2021, dataset = "acs5")

# Select 10 B tables to explore
selected_tables <- paste0("B", sprintf("%02d", c(1, 2, 8, 15, 17, 19, 23, 25, 27, 28)))
selected_vars <- acs_vars %>%
  filter(substr(name, 1, 3) %in% selected_tables)

# Step 4: Define variables for analysis (one per B table)
selected_vars <- c(
  total_population = "B01001_001",         # Total population
  old_population = "B01001_020",           # Old population
  white_population = "B02001_002",         # White population
  local_workers = "B08007_003",            # Workers living and working in the same county
  car_commuters = "B08006_002",            # Workers commuting by car
  bachelor_degree_or_higher = "B15003_022",# Bachelor's degree or higher
  below_poverty = "B17001_002",            # Population below poverty level
  median_income = "B19013_001",            # Median household income
  civilian_labor_force = "B23025_003",     # Total civilian labor force
  renter_occupied = "B25003_003",          # Renter-occupied housing units
  health_insurance = "B27001_001",         # Total with health insurance
  total_households = "B28002_001",         # Total families
  internet_access = "B28002_002"           # Internet access households

)
# Fetch ACS data for selected variables
acs_data <- get_acs(
  geography = "state",
  variables = selected_vars,
  year = 2021,
  survey = "acs5",
  output = "wide"
)

# Calculate derived percentages
acs_data <- acs_data %>%
  mutate(
    old_population = (old_populationE / total_populationE) * 100,
    white_population = (white_populationE / total_populationE) * 100,
    car_commute = (car_commutersE / total_populationE) * 100,
    local_workers = (local_workersE / total_populationE) * 100,
    bachelor_degree = (bachelor_degree_or_higherE / total_populationE) * 100,
    renter_occupied = (renter_occupiedE / total_householdsE) * 100,
    health_insurance = (health_insuranceE / total_populationE) * 100,
    below_poverty = (below_povertyE / total_populationE) * 100,
    internet_household = (internet_accessE / total_householdsE) * 100
  ) %>%
  # Select 10 variables
  select(
    state = NAME,
    old_population,
    white_population,
    car_commute,
    local_workers,
    bachelor_degree,
    renter_occupied,
    median_income = median_incomeE,
    health_insurance,
    below_poverty,
    internet_household
  )

# Save the dataset for analysis or Shiny app
write.csv(acs_data, "acs_final_dataset.csv", row.names = FALSE)

# Display a preview
head(acs_data)
