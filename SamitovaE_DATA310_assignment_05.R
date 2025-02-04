##################################
# Load Required Packages
##################################

install.packages(c("tidyverse", "readxl", "DBI", "RSQLite", "RJSONIO"))

library(tidyverse)
library(readxl)    # for Excel files
library(DBI)       # for working with databases
library(RSQLite)   # for working with SQL databases
library(RJSONIO)   # for working with JSON files


##################################
# Step 1: Set Working Directory
##################################

setwd("C:/Users/Business/OneDrive/__Личное__/BELLEVUE COLLEGE/DATA 310")
getwd()


##################################
# Step 2: Read a CSV File from the Working Directory
##################################

mortality_data <- read_csv("child_mortality_rates.csv")
print(head(mortality_data))  # Check first few rows
str(mortality_data)          # Check structure


##################################
# Step 3: Read a CSV File from a Website
##################################

url <- "https://data.cdc.gov/api/views/v6ab-adf5/rows.csv"
mortality_data_web <- read_csv(url, show_col_types = FALSE)
print(head(mortality_data_web))  # Display first few rows


##################################
# Step 4: Read an Excel File
##################################

mortality_data_excel <- read_excel("child_mortality_rates-1.xlsx", sheet = 1)
print(head(mortality_data_excel))  # Check first few rows


##################################
# Step 5: Download & Read a CSV File
##################################

url <- "http://projects.fivethirtyeight.com/general-model/president_general_polls_2016.csv"
dest_file <- "polls.csv"

download.file(url, dest_file, mode = "wb")

# Read the downloaded CSV file with error handling
polls <- read_csv(dest_file, show_col_types = FALSE, guess_max = 10000)

# Check for parsing issues
if (nrow(problems(polls)) > 0) {
  print("⚠ Warning: Parsing issues detected!")
  print(problems(polls))
}

print(head(polls))  # Display first few rows


##################################
# Step 6: Work with SQLite Database (Fires Data)
##################################

# Unzip the SQLite file properly
unzip("fires.zip", list = TRUE)  # Check contents again

unzip("fires.zip", files = "Data/FPA_FOD_20170508.sqlite", exdir = ".")
file.rename("Data/FPA_FOD_20170508.sqlite", "fires.sqlite")
unlink("Data", recursive = TRUE)  # Remove extracted folder

# Connect to the database
db_file <- "fires.sqlite"
con <- dbConnect(SQLite(), db_file)

# List tables and fields
print(dbListTables(con))
print(dbListFields(con, "Fires"))

# Query data from the database
fires_sql <- "
  SELECT fire_name, fire_size, state, fire_year,
         DATETIME(discovery_date) AS discovery_date
  FROM Fires
"
response <- dbSendQuery(con, fires_sql)
fires <- as_tibble(dbFetch(response))

print(head(fires))  # Display first few rows

# Close database connection
dbClearResult(response)
dbDisconnect(con)


##################################
# Step 7: Read Data from a JSON File
##################################

# download the JSON file
json_url <- "https://www.murach.com/python_analysis/shots.json"
download.file(json_url, "shots.json")

# read JSON data into a variable
json_data <- fromJSON("shots.json")

# use RStudio to explore json_data and get the indexes
# for the column names and rows
column_names <- json_data[["resultSets"]][[1]][["headers"]]
rows <- json_data[["resultSets"]][[1]][["rowSet"]]

# create an empty data frame
shots <- data.frame()

# loop through each row and add to data frame
for (row in rows) {
  shots <- rbind(shots, row)
}

# set the column names
names(shots) <- column_names

# convert data frame to tibble
shots <- as_tibble(shots)
shots

print(head(shots))  # Display first few rows
