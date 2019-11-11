# This program assumes you are starting in the UCI HAR Dataset directory
# Goals for this programming assignment. The program should:
# - Merge the training and the test sets to create one data set.
# - Extract only the measurements on the mean and standard deviation for each measurement. 
# - Use descriptive activity names to name the activities in the data set
# - Appropriately label the data set with descriptive variable names. 
# - From the data set in step 4, create a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.

library(crayon)
library(stringr)
library(dplyr)

# set initial parameters.  Can change to fit different data directories
root_dir <- "/home/cybernaif/Documents/R/UCI HAR Dataset"
setwd(root_dir)
features_file <- "./features.txt"
save_data <- FALSE # flag on whether to save the combined data sets

features <- read.csv(features_file, sep = ' ', header = FALSE)
names(features) <- c("index", "measure")
features$measure <- as.character(features$measure)
  
# adds letter to feature names that are repeated to make them unique
tmp <- table(features$measure)
Features <- names(tmp[tmp>1])
for (Name in Features) {
  found <- features$measure[features$measure==Name]
  found <- found %+% letters[1:length(found)]
  features$measure[features$measure==Name] <- found
}

get_paths <- function(Dir) {            # get file names with paths in dir
  Files <- dir(Dir)               # get all file names in dir
  Dir %+% "/" %+% Files           # create path to text files
}

text_files <- function(Dir) {   # get list of text files in dir and subdir
  files <- get_paths(Dir)         # get file names with paths
  txt_files <- files[grep(".txt", files)] # extract the text file names
  sub_dir <- setdiff(files, txt_files)    # identify the sub directory
  sub_files <- get_paths(sub_dir) # get sub directory text files
  c(sub_files, txt_files)         # concatenate lists 
}

extract_data <- function(File, features) { # Extract values from file data
  data <- read.table(File)        # read file data into table
  # if this is one of the files with 561 variables, label them
  if (length(names(data)) == length(features$measure)) {
    names(data) <- features$measure
  }
  data
}

id_text_files <- function() {                   # get text files with paths
  Dirs <- c("./test", "./train")          # set dirs to explore
  all_files <- c()                        # buffer for file names
  for (Dir in Dirs) {                     # get paths to all .txt files
    Files <- text_files(Dir)        # get files in directory
    all_files <- c(all_files, Files)# add to the buffer
  }
  all_files
}

create_combined <- function(save_data) { # create folder to hold combined data
  if (save_data == TRUE) { # if we are saving the combined data
    comboExists <- file.exists("./combined")# check if folder exists
    if (!comboExists) {              # if data folder doesn't exist
      dir.create("./combined") # create folder
    }
  }
}

read_combined <- function(features, Names, combined) {
  Files <- dir("./combined")
  for (File in Files) {
    together <- extract_data("./combined/" %+% File, features)
    combined[[length(combined)+1]] <- list(together) # add combined data to list
    Names <- c(Names, sub(".txt", "", File)) # combined data names
  }
  names(combined) <- Names # label combined data sets based on file names
  combined
}

# - Merge the training and the test sets to create one data set.
combine_data <- function(features, save_data, all_files) {
  tests <- all_files[grep("^./test", all_files)]  # extract test data files
  train <- all_files[grep("^./train", all_files)] # extract training data files
  
  create_combined(save_data) # create folder to hold the combined data sets
  
  combined <- list()
  Names <- c()
  if (!save_data | !file.exists("./combined")) {
    # This loops through the test and training files, and combines the data sets
    # The different data sets are both saved to disk and put into a list
    for (File in tests) {
      name <- strsplit(File, '/')[[1]]        # split path to test file
      name <- name[length(name)]              # get file name
      
      other <- sub('test','train', name)      # get equiv train file name
      other <- grep('/' %+% other, all_files) # id index in all files list
      other <- all_files[other]               # get full path
      
      test <- extract_data(File, features)    # read in the two files
      train <- extract_data(other, features)
      together <- rbind(test, train)          # concatenate the tables
      
      # extend list of file name and combined test/train data pairs
      combined[[length(combined)+1]] <- list(together) # add combined data to list
      file_name <- sub('test','combo', name)  # file for combined data
      Names <- c(Names, sub(".txt", "", file_name)) # combined data names
      
      # save the combined data for evaluation
      if (save_data == TRUE) {  # if we are saving the data at this step
        Path <- "./combined/" %+% file_name  # path to combined data
        write.table(together, Path)          # write out combined data
      }
    }
    names(combined) <- Names # label combined data sets based on file names
  }
  
  else {
    combined <- read_combined(features, Names, combined)
  }
  
  combined
}

# - Extract only the measurements on the mean and standard deviation for each measurement.
get_columns <- function(my_table, substrings) {
  indices <- c()
  for (strng in substrings) {
    tmp <- grep(strng, names(my_table))
    indices <- c(indices, tmp)
  }
  my_table[sort(indices)]
}

rounder <- function(t) { # format time values to show seconds to two decimal places
  format(round(t, 2), nsmall = 2)
}

select_data_sets <- function(combined) { # get the names of the data set files
  Names <- names(combined)                        # get all data names
  data_sets <- grep('total', Names)               # grab those with 'total'
  data_sets <- c(data_sets, grep('body', Names))  # and with 'body' in the name
  Names[sort(data_sets)]
}

# - Use descriptive activity names to name the activities in the data set
addActivityNames <- function(combined) {
  activities <- combined$y_combo[[1]]               # get the activity label codes
  codes <- read.table("./activity_labels.txt")      # get codes to activities
  merged <- merge(activities, codes)                # match activities to codes
  names(merged) <- c("code","activity")             # label the columns
  combined$y_combo[[1]]$V1 <- merged$activity       # replace codes with activities
  
  Names <- select_data_sets(combined)               # get names of the data sets
  for (Name in Names) {                             # for each data set
    data <- combined[[Name]][[1]]             # get the data 
    # add activity column
    data <- data %>% mutate(activity = merged$activity) 
    combined[[Name]] <- list(data)            # put data back in list
  }
  combined
}

# - Appropriately label the data set with descriptive variable names.
label_rows_cols <- function(combined) {
  data_sets <- select_data_sets(combined)               # get the data set names
  for (Name in data_sets) {                             # for each data set
    subSet <- combined[[Name]][[1]]               # get the data 
    sample_times <- 0:127 * 0.02                  # get the sample times
    sample_times <- sapply(sample_times, rounder) # set decimal places to 2
    prefix <- sub("combo","", Name)               # remove combo from name
    new_labels <- prefix %+% sample_times         # add sample times to name
    new_labels <- c("activity", new_labels)       # put "activity" label 1st
    activityIndex <- grep("activity", names(subSet))[1]
    subSet <- cbind(subSet$activity, subSet[-activityIndex])
    
    names(subSet) <- new_labels                   # assign the new names 
    combined[[Name]] <- list(subSet)              # save data set back to list
  }
  combined
}

consolidateSourceData <- function(combined) {
  all_data <- data.frame()
  data_sets <- select_data_sets(combined) # get Inertial Signal data set names
  for (Name in data_sets) {                             # for each data set
    subSet <- combined[[Name]][[1]]               # get the data 
    if (dim(all_data)[1]==0) {                    # if 1st time        
      all_data <- subSet                    # Use 1st data frame
    }
    else {
      # add the other data frames without the activity column
      activityIndex <- grep("activity", names(subSet))[1]
      all_data <- cbind(all_data, subSet[-activityIndex])
    }
  }
  all_data
}

get_means <- function(data) { # group data by subject & activity, take means
  # add subject and activity columns to the data
  data$subject <- combined$subject_combo[[1]]$V1
  data$activity <- combined$y_combo[[1]]$V1
  
  grouped_data <- data %>% group_by(subject, activity) # group_by
  means <- summarise_all(grouped_data, mean)      # Get mean for each
  means 
}



# - From the data set in step 4, create a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.
get_group_means <- function(combined) {
  # wasn't sure if data set was inertial data or data with 561 features
  # so did both
  all_data <- consolidateSourceData(combined) # consolidate Inertial data
  # featured_data <- combined$X_combo[[1]]      # get data with 561 features
  filtered_data <- combined$filtered_cols[[1]]# get filtered data
  
  all_data_means <- get_means(all_data)       # get mean of variables for
  # featured_means <- get_means(featured_data)  # each subject, activity combo 
  filtered_means <- get_means(filtered_data)
  
  combined$data_means <- list(all_data_means)
  # combined$featured_means <- list(featured_means)
  combined$filtered_means <- list(filtered_means)
  
  combined
}

save_results <- function(combined) {
  resultsExists <- file.exists("./results")# check if folder exists
  if (!resultsExists) {              # if results folder doesn't exist
    dir.create("./results")    # create folder
  }
  Names <- names(combined)
  for (Name in Names) {
    data <- combined[[Name]][[1]]
    fileName <- "./results/" %+% Name %+% ".Rda"
    saveRDS(data, file = fileName)
  }
}



# - Merge the training and the test sets to create one data set.
# Performed on both the X_test/X_train files and on the Inertial Signals data
# All combined data files saved in a list named "combined".
all_files <- id_text_files()
combined <- combine_data(features, save_data, all_files)

# - Extract only the measurements on the mean and standard deviation for each 
#   measurement.
# The combined X_test/X_train file data was labeled using the 561 feature names
# and the selected mean & std dev columns saved in the combined data list
substrings <- c("std", "mean")
filtered <- get_columns(combined$X_combo[[1]], substrings)
combined$filtered_cols <- list(filtered)

# - Use descriptive activity names to name the activities in the data set
# Added activities column (WALKING, WALKING_UPSTAIRS, etc.) to combined X_test/
# X_train file data, and to # Inertial Signal data sets
combined <- addActivityNames(combined)

# - Appropriately label the data set with descriptive variable names.
# Inertial data sets consist of rows of 128 values, representing measurements each 0.02 
# sec therefore columns will be named for data source (e.g. total_acc_x) plus time offset
# rows will be named based on the start time relative to the first sample period
# The modified data set tables will then be saved back in the combined data list
# The combined X data set was labeled with feature names in step 2
combined <- label_rows_cols(combined)

# - From the data set in step 4, create a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.
# Performed on both a combined Inertial Signal data set and on X data set
# Project instructions unclear on what data set was requested.
combined <- get_group_means(combined)

save_results(combined)