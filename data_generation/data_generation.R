library(dplyr)
library(tidyr)
library(stringr)

data_bbc <- read.csv("bbc.csv", header=TRUE, stringsAsFactors = FALSE, sep=",") 
data_abc <- read.csv("abc.csv", header=TRUE, stringsAsFactors = FALSE) 
data_cnn <- read.csv("cnn.csv", header=TRUE, stringsAsFactors = FALSE) 
data_fox <- read.csv("fox.csv", header=TRUE, stringsAsFactors = FALSE) 
data_LA_times <- read.csv("la_times.csv", header=TRUE, stringsAsFactors = FALSE) 

dataset <-rbind(data_bbc, data_abc ,data_cnn, data_fox, data_LA_times)
colnames(dataset)[1] <- 'id'
dataset <- dataset %>% tidyr::separate(posted_at, c("date", "hour"), " ", remove = FALSE)
dataset$date <- as.Date(dataset$date)
dataset$posted_at <- as.POSIXlt(dataset$posted_at)
dataset <- apply(dataset,2717705,as.character)

dataset$message <- as.character(dataset$message)
dataset$id <- stringr::str_replace(dataset$id,"﻿", "")
dataset$caption <- NULL
dataset$link <- NULL
dataset$picture <- NULL

remove_emojis <- function(string) {
  #print(string)
  string_as_int <- string %>%
    utf8ToInt()
  # replace with empty space 
  string_as_int[which(string_as_int > 100000)] <- 160
  intToUtf8(string_as_int)
}

dataset$message <- lapply(dataset$message,function(x) remove_emojis(x))
dataset$description <- lapply(dataset$description,function(x) remove_emojis(x))
dataset <- dataset[dataset$message!="NULL" & dataset$message!="" ,]
dataset$description[dataset$description=="NULL" | dataset$description==" "]<-"not provided"

write.csv(dataset, '../dashboard/facebook_dataset.csv', row.names = F)