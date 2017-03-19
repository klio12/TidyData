##setwd("C:/Users/Nebo/Documents/School/Coursera/R/ProgrammingAssignment4/UCI HAR Dataset/")

## load necessary libraries
library(plyr)
library(dplyr)
library(reshape2)	#to load melt() and dcast()

## load activity descriptions
activity_labels<- read.table("activity_labels.txt") ## 6 rows

## load feature list
features<- read.table("features.txt") ## 561 rows

## load training set (21 unique subject IDs and their activities, measurements for all 561 variables)
subject_train<- read.table("train/subject_train.txt")  ## 7352 rows
y_train<-read.table("train/y_train.txt") ## 7352 rows
X_train<-read.table("train/X_train.txt") ## 7352 rows

## load testing set (9 unique subject IDs and their activities, measurements for all 561 variables)
subject_test<- read.table("test/subject_test.txt") ## 2947 rows
y_test<-read.table("test/y_test.txt") ## 2947 rows
X_test<-read.table("test/X_test.txt") ## 2947 rows

## rename column in subject tables
names(subject_test)[names(subject_test)=="V1"]<-"SubjectID"
names(subject_train)[names(subject_train)=="V1"]<-"SubjectID"

## label data set with descriptive variable names
names(X_train)<-features$V2 ## 561 rows
names(X_test)<-features$V2 ## 561 rows

## apply descriptive activity names
y_test<-(merge(y_test, activity_labels, all=F) %>% select(ActivityDescription=V2))
y_train<-(merge(y_train, activity_labels, all=F) %>% select(ActivityDescription=V2))

## add subject and activity IDs to measurement table
X_train<-cbind(subject_train, y_train, X_train)  ##7352 x 563
X_test<-cbind(subject_test, y_test, X_test) ## 2947 x 563

## some column names are duplicate – make them unique to avoid bind_rows() removing the dupes
names(X_train)<-make.names(names(X_train), unique = TRUE, allow_ = TRUE)
names(X_test)<-make.names(names(X_test), unique = TRUE, allow_ = TRUE)

## Merge training and test sets into one dataset
X_TrainTest<-bind_rows(X_train, X_test)  ##10299 563

## Extract only measurements on mean and SD for each measurement
## DO NOT INCLUDE measurements that have angle in their names
MeanStdVariables<-intersect(grep("mean|std", names(X_TrainTest), value=F, ignore.case=T), grep("angle", names(X_TrainTest), value=F, ignore.case=T, invert=T))
X_TrainTestMeanSD<-select(X_TrainTest, SubjectID, ActivityDescription, MeanStdVariables)  ## 10299 x 81

## Create final descriptive variable names by further processing of the labels
a<-names(X_TrainTestMeanSD)
a<-sub("^t", "", a)
a<-gsub("BodyBody", "Body", a)
a<-gsub("Jerk", "_Jerk", a)
a<-gsub("GravityAcc", "LinearAcceleration_GravityComponent",a)
a<-gsub("BodyAcc", "LinearAcceleration_BodyComponent",a)
a<-gsub("BodyGyro", "AngularVelocity", a)
i=0; while (i<length(a)){i=i+1; if(grepl("Mag.", a[i])){a[i]=paste("Magnitude", sub("Mag", "", a[i]), sep="_")}}
a<-gsub("^Magnitude_f", "FFT_Magnitude_", a)
a<-sub("^f", "FFT_", a)
a<-sub(".mean...X$", "_Xaxis_Mean", a)
a<-sub(".mean...Y$", "_Yaxis_Mean", a)
a<-sub(".mean...Z$", "_Zaxis_Mean", a)
a<-sub(".mean..$", "_Mean", a)
a<-sub(".std...X$", "_Xaxis_StandardDeviation", a)
a<-sub(".std...Y$", "_Yaxis_StandardDeviation", a)
a<-sub(".std...Z$", "_Zaxis_StandardDeviation", a)
a<-sub(".std..$", "_StandardDeviation", a)
a<-sub(".meanFreq...X$", "_Xaxis_MeanFrequency", a)
a<-sub(".meanFreq...Y$", "_Yaxis_MeanFrequency", a)
a<-sub(".meanFreq...Z$", "_Zaxis_MeanFrequency", a)
a<-sub(".meanFreq..$", "_MeanFrequency", a)
names(X_TrainTestMeanSD)<-a

## From data in #4, create second, independent tidy data set with average of each variable, for each activity and each subject
## create all combinations of Subject identifiers and activities
subAct<-merge(sort(unique(X_TrainTestMeanSD$SubjectID)), activity_labels$V2)  ## 180 x 2
names(subAct)<-c("SubjectID", "ActivityDescription")

## calculate mean values for all subject-activity combinations that exist in the dataset
X_TrainTestMeanSD <-(
melt(X_TrainTestMeanSD, id=c("SubjectID", "ActivityDescription")) %>%
dcast(SubjectID + ActivityDescription ~ variable, mean)
) ## 40 x 81

## append calculated means for existing subject-activity combinations to the full list of subject-activity combinations
X_TrainTestMeanSD <-merge(subAct, X_TrainTestMeanSD, by.y=c("SubjectID", "ActivityDescription"), by.x=c(names(subAct)<-c("SubjectID", "ActivityDescription")), all=T) ## 180 x 81

## create a text file containing tidy data set
write.table(X_TrainTestMeanSD, "TidyDataSet.txt")
