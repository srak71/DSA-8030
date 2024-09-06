# Saransh Rakshak Assignment: Tidying Data
library(tidyverse)

relig_income

relig_income |> 
  pivot_longer(!religion, names_to = "income", values_to = "count")


relig_income |> 
  pivot_longer(`<$10k`:`Don't know/refused`, names_to = "income", values_to = "count")


# Showing weeks and rank
billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank",
    values_drop_na = TRUE
  )

# Weeks to int
billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    names_prefix = "wk",
    names_transform = list(week = as.integer),
    values_to = "rank",
    values_drop_na = TRUE,
  )

# Sorted list of songs and the number of weeks that song stayed on the chart,

B <- billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    names_prefix = "wk",
    names_transform = list(week = as.integer),
    values_to = "rank",
    values_drop_na = TRUE,
  )

B %>% 
  group_by(artist, track) |> 
  summarize(NumWeeks= max(week)) |>
  arrange(desc(NumWeeks))

##############
# Exercise 1 #
##############
table4a

table4a_fixed <- table4a |>
  pivot_longer(
    cols = -country,
    names_to = "year",
    values_to = "cases"
  )

table4a_fixed


