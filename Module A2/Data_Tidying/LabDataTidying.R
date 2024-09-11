# Saransh Rakshak Assignment: Tidying Data
library(tidyverse)

relig_income

##################
# pivot_longer() #
##################

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

table4a |>
  pivot_longer(
    cols = -country,
    names_to = "year",
    values_to = "cases"
  )





#################
# pivot_wider() #
#################
library(tidyr)
fish_encounters

# Number of encounters at each 'station' for each 'fish'
fish_encounters |> pivot_wider(names_from = station, values_from = seen)

# Fill NA with 0
fish_encounters |> 
  pivot_wider(
    names_from = station, 
    values_from = seen,
    values_fill = 0
  )


#set pivot_wider dataset to an object (x)
x <- fish_encounters |> 
  pivot_wider(
    names_from = station, 
    values_from = seen,
    values_fill = 0
  )

#find the sum of the Lisbon variable (this counts the number of detection)
sum(x$Lisbon)




##############
# Exercise 2 #
##############
table2

table2 |> 
  pivot_wider(
    names_from = type,
    values_from = count
)



##############
# Separate() #
##############
bbNew <- billboard |> 
  select(artist:date.entered)
bbNew

# separating by 'date' to 'year', 'month', 'day'
bbNew |>
  separate(col=date.entered, into=c("year", "month", "day"))

# converting character vars to numerical
bbNew |>
  separate(col=date.entered, 
           into=c("year", "month", "day"), 
           sep="-", 
           convert = TRUE)


# adding a 'century' column from 'year'
df1 <- bbNew |>
  separate(col=date.entered, 
           into=c("year", "month", "day"), 
           sep="-", 
           convert = TRUE)
df2 <- df1 |>
  separate(col=year, into=c("century", "year"), sep = 2)
df2



##############
# Exercise 3 #
##############
table3

table3 |>
  separate(col = rate,
           into = c("cases", "population"),
           sep ="/",
           convert = TRUE)



###########
# Unite() #
###########
df2 |>
  unite(col="year_new", century, year, sep = "")


##############
# Exercise 4 #
##############
who

who1 <- who |>
  pivot_longer(
    cols = starts_with("new"), 
    names_to = "key", 
    values_to = "cases",
    values_drop_na = TRUE
  )

who1

who1 %>% 
  count(key)

# replacing characters 'newrel' with 'new_rel'  to make all var names consistent
who2 <- who1 %>% 
  mutate(key = stringr::str_replace(key, "newrel", "new_rel"))
who2

who3 <- who2 |>
  separate(
    col = key,
    into = c("new", "type", "sexage"),
    sep = "_",
    convert = TRUE
  )

who3

who3 %>% 
  count(new)

who4 <- who3 %>% 
  select(-new, -iso2, -iso3)

who4

# separate into sex and age by splitting after first character
who5 <- who4 |>
  separate(
    col = sexage,
    into = c("sex", "age"),
    sep = 1,
    convert = TRUE
  )

who5