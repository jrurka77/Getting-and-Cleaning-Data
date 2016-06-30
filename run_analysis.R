library(RCurl)  
 
if (!file.info('UCI HAR Dataset')$isdir) {    dataFile <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'    dir.create('UCI HAR Dataset') 
	download.file(dataFile, 'UCI-HAR-dataset.zip', method='curl') 
  	unzip('./UCI-HAR-dataset.zip') 



**install required libraries

library(data.table)
library(dplyr)

**Read Supporting Metadata

featurenames <- read.table("UCI HAR Dataset/features.txt")
activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)

**Read training data

subjtrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
acttrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuretrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)

**Read test data

subjtest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
acttest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featurestest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)

** Merge the training and the test data 

subject <- rbind(subjtrain, subjtest)
activity <- rbind(acttrain, acttest)
features <- rbind(featuretrain, featurestest)

** Name the Features column

colnames(features) <- t(featurenames[2])

** Merge all data to make one large dataset

colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
completedata <- cbind(features,activity,subject)

**Find measurements with mean and SD only

MeanSTD <- grep(".*Mean.*|.*Std.*", names(completedata), ignore.case=TRUE)
requiredcolumns <- c(MeanSTD, 562, 563)
extracteddata <- completedata[,requiredcolumns]

**Assign activity names to dataset
extracteddata$activity <- as.character(extracteddata$activity)
for (i in 1:6){
extracteddata$activity[extracteddata$activity == i] <- activitylabels[i,2]
}

**Review the extracteddata names to determine if the names are clear

names(extracteddata)	

**Edit names so they are clearer to understand

names(extracteddata)<-gsub("Acc", "Accelerometer", names(extracteddata))
names(extracteddata)<-gsub("Gyro", "Gyroscope", names(extracteddata))
names(extracteddata)<-gsub("BodyBody", "Body", names(extracteddata))
names(extracteddata)<-gsub("Mag", "Magnitude", names(extracteddata))
names(extracteddata)<-gsub("^t", "Time", names(extracteddata))
names(extracteddata)<-gsub("^f", "Frequency", names(extracteddata))
names(extracteddata)<-gsub("tBody", "TimeBody", names(extracteddata))
names(extracteddata)<-gsub("-mean()", "Mean", names(extracteddata), ignore.case = TRUE)
names(extracteddata)<-gsub("-std()", "STD", names(extracteddata), ignore.case = TRUE)
names(extracteddata)<-gsub("-freq()", "Frequency", names(extracteddata), ignore.case = TRUE)



**Create a tidy dataset

extracteddata$subject <- as.factor(extracteddata$Subject)
extracteddata <- data.table(extracteddata)

tidyData <- aggregate(. ~Subject + Activity, extracteddata, mean)
tidyData <- tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)