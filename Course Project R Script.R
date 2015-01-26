
## set the standard working directory and the download path, and download the project ZIP file
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
workdirectory <- "/Users/Robert/Dropbox/Coursera/3 Getting And Cleaning Data/Project"
setwd(workdirectory)
download.file(fileURL, "datafile", method = "curl")

## unzip the datafile
unzip("datafile")

## read relevant data files into data frames
traindata <- read.table("./UCI HAR Dataset/train/X_train.txt")
testdata <- read.table("./UCI HAR Dataset/test/X_test.txt")

train_y <- read.table("./UCI HAR Dataset/train/y_train.txt")
test_y <- read.table("./UCI HAR Dataset/test/y_test.txt")

train_subs <- read.table("./UCI HAR Dataset/train/subject_train.txt")
test_subs <- read.table("./UCI HAR Dataset/test/subject_test.txt")

features <- read.table("./UCI HAR Dataset/features.txt")
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")

## bind the activity and subject columns to the data
train_full <- cbind(traindata,train_y,train_subs)
test_full <- cbind(testdata,test_y,test_subs)

## merge the train data rows with the test data rows
all_data <- rbind(train_full,test_full)
activity_codes <- rbind(train_y,test_y)

## use the labels in "features.txt" as new column labels for the data
new_names <- as.character(features[,2])
new_names <- c(new_names,"ACTIVITIES","SUBJECTS")
colnames(all_data) <- new_names

## create a logical vector that is true for data columns whose column name includes "mean()" or "sub()"
meanlogical <- grepl("mean()",new_names)
stdlogical <-grepl("std()", new_names)
all_logical <- meanlogical | stdlogical
## make the last 2 values in the vector TRUE to ensure we include the columns with ACTIVITIES and SUBJECTS
all_logical[562:563] <- TRUE
## keep in relevant_data only the columns for which the logical vector is TRUE
## i.e. the mean() or std() columns plus ACTIVITIES, SUBJECTS
relevant_data <- all_data[,all_logical]
relevant_names <- names(relevant_data) 
## get rid of columns 4-79 since we only want to summarize a few of the variables to illustrate
## the tidy set, add an "Activity" column that will store the "readable" activity type
relevant_data <- cbind(relevant_data[,-4:-79],c("Activity")
colnames(relevant_data) <- c("tBodyAccX", "tBodyAccY", "tBodyAccZ", "ACTIVITIES", "SUBJECTS", "Activity")
relevant_data$Activity <- activities[relevant_data$ACTIVITIES,2]

## install dplyr for summarization operations
install.packages("dplyr")
library(dplyr)

## group by and summarize
grouped <- group_by(relevant_data,SUBJECTS,Activity)
## use only one of the means variable, since this is for illustration only, named tBodyAccX
tidy_means <- summarise(grouped,mean(tBodyAccX))

## write the tidy data set to the file in the Repo directory to be forked to GIT
write.table(tidy_means,file = "./Project Repo/tidy.csv", sep = ",")




