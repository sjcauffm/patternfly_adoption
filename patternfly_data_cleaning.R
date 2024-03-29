library(rjson)
library(jsonlite)
library(googlesheets)
library(tidyverse)

#### Cleaning PF Data ####
dir <- setwd("~/Google Drive File Stream/My Drive/UXD-Share/Usability and User Research/Studies 2019/PatternFly Adoption Visualization/patternfly-analytics-master/stats")

files <- list.files(path = dir) ### gets the list of JSONs from the directory
files <- files[c(1:13,15:21)] ### Gets rid of a file that is not a JSON

import <- lapply(files, fromJSON) ### reads data from all JSONs in directory to a list

dfc <- map_df(files, function(i) {
  
  files <-  i #get file name
  
  #convert file name to r-friendly
  r_name <- gsub("-","_",files) 
  r_name <- gsub(" ","_",r_name)
  r_name <- gsub("\\.json","",r_name)
  
  #define file path based on file name and wd
  file_path <- paste0("~/Google Drive File Stream/My Drive/UXD-Share/Usability and User Research/Studies 2019/PatternFly Adoption Visualization/patternfly-analytics-master/stats/"
                      ,files)
  
  #connect json file
  json <- file(file_path)
  
  #json to r
  raw<- fromJSON(paste(readLines(json,warn=F), collapse="")) #read json into list
  df <- as.data.frame(unlist(raw,use.names = T)) #unlist into df
  
  df$product <- r_name #keep product name from file name
  
  df <- rownames_to_column(df) #get list definitions to row
  
  df
})

extra <- grep("files.", dfc$rowname)
dfc2 <- dfc[-extra,]

x <- grep("date", dfc$rowname)
y <- dfc[x,]

dfc3 <- full_join(dfc2, y, by = "product")

names(dfc3) <- c("full_component", "imports", "product", "extra", "date")
dfc3 <- dfc3[,c(1:3,5)]

dump_dates <- grep("date", dfc3$full_component)
dump_repo <- grep("repo", dfc3$full_component)
dump_name <- grep("name", dfc3$full_component)

dfc4 <- dfc3[-c(dump_dates, dump_repo, dump_name),]
