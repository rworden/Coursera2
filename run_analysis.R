### Objectives (numbers mine)
# 1) You should create one R script called run_analysis.R that does the following. 
# 2) Merges the training and the test sets to create one data set.
# 3) Extracts only the measurements on the mean and standard deviation for each measurement. 
# 4) Uses descriptive activity names to name the activities in the data set
# 5) Appropriately labels the data set with descriptive variable names. 
# 6) Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

### Thoughts
# wtf is going on with this table structure.
# I think subject_train, X_train, and y_train can be merged on row no, given same row numbers for each...yay for implicit keys...
# then, ostensibly we can append/rbind the test and train data together
# then take features.txt and transpose them to the var names for x_train. TODO: replace commas with something else in field names

### Decisions
# Disregard "Intertial Signals" stuff for now

### Questions
# re:6, looks like these measures are a mean/sd over the fixed time period. So we're averaging averages and sd's, which feels funny but ok
# or am I supposed to perform these calcs on the raw data and roll up? Or both. Worst case, compute mean for everything, still includes minimum targets

### setup
setwd("/Users/rworden/Coursera2/")

### download files initially (run once)
 url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
 download.file(url,destfile="runAnalysis.zip",method="curl")
 unzip("runAnalysis.zip")
###

# input and process activity_labels.txt and y_train.txt
# add a new column with text label for each numeric label
activityLabels<-read.table("./UCI HAR Dataset/activity_labels.txt")
names(activityLabel)<-c("activityCode","activityDescription")

# load y_train.txt 
# then merge with activityLabels
# TODO should prob throw an error if pre and post row counts differ.
yTrain<-read.table("./UCI HAR Dataset/train/y_train.txt")
names(yTrain)<-"activityCode"
yTrain<-merge(yTrain,activityLabels,by.x="activityCode",by.y="activityCode")

# load y_test.txt
# then merge with activityLabels
# TODO should prob throw an error if pre and post row counts differ.
yTest<-read.table("./UCI HAR Dataset/test/y_test.txt")
names(yTest)<-"activityCode"
yTest<-merge(yTest,activityLabels,by.x="activityCode",by.y="activityCode")

# input and process features.txt
## TODO(?) remove commas in label names? meh
featureLabels<-read.table("./UCI HAR Dataset/features.txt")
featureLabels$V1<-NULL
colnames(featureLabels)<-"feature"
#featureLabels$feature<-as.character(featureLabels$feature)

## why does replacing commas break everything and make it not a vector?
# replace "," with "|" because wtf would you put commas in a fieldname
# featureLabels<-gsub("\\,","\\|",featureLabels$feature)
##

# turn features.txt into character var separated by quotes and commas for use in names()
# holy hell, there is probably a much better way to do this
i<-1
featureLabelsTransform<-character()
for(i in i:nrow(featureLabels)) {
    featureLabelsTransform<-rbind(featureLabelsTransform,gsub(" ","",(paste("",as.character(featureLabels[i,]),""))))
    i<-i+1
}

# TEST data
## ingest test data
X_test<-read.table("./UCI HAR Dataset/test/X_test.txt")
# label each column in X_test.txt with featureLabels
names(X_test)<-featureLabelsTransform

# TRAIN data
# label each column in X_train.txt with featureLabels
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt")
# label each column in X_test.txt with featureLabels
names(X_train)<-featureLabelsTransform


