library(tidyverse)
library(csgjcr)

agency <- read_rds(csg_sp_path("jr_data_library", "data", "analysis", "fbi",
                               "kaplan", "fbi_kaplan_okca_agency.rds")) |> 
  filter(state_abbr == "CA", number_of_months_reported == 12)

agency |> 
  select(-state_fips, -number_of_months_missing, -number_of_months_reported) |> 
  rename(offense = group) |>
  write_csv("ca_reported_crime_by_agency.csv")
