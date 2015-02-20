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
X_test <- read.table("./test/X_test.txt")
testSubject <- read.table("./test/subject_test.txt")
testActivity <- read.table("./test/y_test.txt")

# combine the test data
allTest <- cbind(testSubject, testActivity, X_test)

# remove data no longer needed
rm(X_test, testSubject, testActivity)

#
# read the train data
#
X_train <- read.table("./train/X_train.txt")
trainSubject <- read.table("./train/subject_train.txt")
trainActivity <- read.table("./train/y_train.txt")

# combine the train data
allTrain <- cbind(trainSubject, trainActivity, X_train)

# remove data no longer needed
rm(X_train, trainSubject, trainActivity)

#
# combine the test and train data
#
allData <- rbind(allTest, allTrain)

# remove data no longer needed
rm(allTest, allTrain)

#
# create a logical vector used to select the columns for the final data set
#
selCols <- grepl(".*std\\(\\).*|.*mean\\(\\).*", features$colname)

# select the activity, subject, and standard deviation and mean measurements
allStdMean <- allData[, c(TRUE, TRUE, selCols)]

# change the activity column to a factor using the
# data from the activity_labels.txt file
allStdMean[,2] <- factor(allStdMean[,2], levels=actLabels$actno,
                      labels=actLabels$actname)

#
# get the column names and clean them
#
tidyCols <- features$colname[selCols]
tidyCols <- sub("-std\\(\\)", "Std", tidyCols)          # change -std() to Std
tidyCols <- sub("-mean\\(\\)", "Mean", tidyCols)        # change -mean() to Mean
tidyCols <- sub("-", "", tidyCols)                      # remove -'s
tidyCols <- sub("BodyBody", "Body", tidyCols)           # change BodyBody to Body

#
# set the names of the allStdMean dataframe
#
colnames(allStdMean) <- c("subject", "activity", tidyCols)

#
# write allStdMead to a file named tidyData1.txt
#
write.table(allStdMean, file = "tidyData1.txt", row.name = FALSE)

#
# create a dataset with the average of each variable for
# activity and subject
#
tidyData2 <- group_by(allStdMean, subject, activity)    # group data by activity and subject
tidyData2 <- summarise_each(tidyData2, funs(mean))      # calculate average for each group

#
# write the tidyData2 data to a file
#
write.table(tidyData2, file = "tidyData2.txt", row.name = FALSE)
