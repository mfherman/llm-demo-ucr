library(tidyverse)

ca_data_raw <- read_csv("data/ca_reported_crime_by_agency.csv")

ca_data <- ca_data_raw |> 
  mutate(
    reported_per100k = n_reported / pop_jurisdiction * 1e5,
    solve_rate = 1 - unsolved_rate
  ) |> 
  select(
    year, agency_name, agency_type, pop_group, pop_jurisdiction,
    offense, n_reported, reported_per100k, n_solved = n_cleared, n_unsolved, solve_rate
  )

write_rds(ca_data, "ca_data.rds")
