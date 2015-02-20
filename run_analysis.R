#
# The working directory for this script must contain the unzipped
# UCI HAR Dataset.
#

# set the working directory and remove all objects from the environment
setwd("~/Desktop/datascientist/UCI HAR Dataset")
rm(list = ls(all.names = TRUE))

# load some libraries
library(data.table)
library(dplyr)

#
# read the activity_labels.txt file - activity number and name
#
actLabels <- read.table("activity_labels.txt", col.names=(c("actno", "actname")),
                        stringsAsFactors=FALSE)

#
# read the feature.txt file - column number and name of the features
#
features <- read.table("features.txt", col.names=(c("colno", "colname")),
                       stringsAsFactors=FALSE)

#
# read the test data
#
X_test <- read.table("./test/X_test.txt", col.names = features$colname)
testSubject <- read.table("./test/subject_test.txt", col.names = "subject")
testActivity <- read.table("./test/y_test.txt", col.names = "activity")
testFactor <- factor(testActivity$activity, levels=actLabels$actno,
                     labels=actLabels$actname)

# combine the test data and change activity column name
allTest <- cbind(testFactor, testSubject, X_test)
colnames(allTest)[1] <- "activity"

# clean up some data no longer needed
rm(X_test, testSubject, testActivity, testFactor)

#
# read the train data
#
X_train <- read.table("./train/X_train.txt", col.names = features$colname)
trainSubject <- read.table("./train/subject_train.txt", col.names = "subject")
trainActivity <- read.table("./train/y_train.txt", col.names = "activity")
trainFactor <- factor(trainActivity$activity, levels=actLabels$actno,
                      labels=actLabels$actname)

# combine the train data and change activity column name
allTrain <- cbind(trainFactor, trainSubject, X_train)
colnames(allTrain)[1] <- "activity"

# clean up some data no longer needed
rm(X_train, trainSubject, trainActivity, trainFactor)

#
# combine the test and train data
#
allData <- rbind(allTest, allTrain)

#
# create a logical vector used to select the columns for the final data set
#
selCols <- grepl(".*std\\(\\).*|.*mean\\(\\).*|.*meanFreq\\(\\).*", features$colname)

# select the standard deviation and mean measurements
allStdMean <- allData[, c(TRUE, TRUE, selCols)]


#
# get the column names and clean them
#
tidyCols <- features$colname[selCols]
tidyCols <- sub("^([f])(.*)", "F\\2", tidyCols)         # uppercase f at beginning of name
tidyCols <- sub("^([t])(.*)", "T\\2", tidyCols)         # uppercase t at beginning of name
tidyCols <- sub("-std\\(\\)", "Std", tidyCols)          # change -std() to Std
tidyCols <- sub("-mean\\(\\)", "Mean", tidyCols)        # change -mean() to Mean
tidyCols <- sub("-meanFreq\\(\\)", "MeanFreq", tidyCols) # change meanFreq() to MeanFreq
tidyCols <- sub("-", "", tidyCols)                      # remove -'s
tidyCols <- sub("BodyBody", "Body", tidyCols)           # change BodyBody to Body

#
# set the names of the allStdMean dataframe
#
colnames(allStdMean) <- c("activity", "subject", tidyCols)

#
# write allStdMead to a file named tidyData1.txt
#
write.table(allStdMean, file = "tidyData1.txt", row.name = FALSE)

#
# create a dataset with the average of each variable for
# activity and subject
#

tidyData2 <- group_by(allStdMean, activity, subject)    # group data by activity and subject
tidyData2 <- summarise_each(tidyData2, funs(mean))      # calculate average for each group

tidyCols2 <- sub("^", "avg", tidyCols)                  # add avg to column names
colnames(tidyData2) <- c("activity", "subject", tidyCols2)

#
# write the tidyData2 to a file
#
write.table(tidyData2, file = "tidyData2.txt", row.name = FALSE)


mydata <- read.table("tidyData2.txt", header = TRUE)

#
# clean up remaining data
#
#rm(list=ls())

