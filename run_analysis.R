### Objectives
# You will be required to submit: 
# 1) a tidy data set as described below, 
# 2) a link to a Github repository with your script for performing the analysis, and 
# 3) a code book that describes the variables, the data, and any transformations or work that you performed 
    #to clean up the data called CodeBook.md. 
# You should also include a README.md in the repo with your scripts. 
# This repo explains how all of the scripts work and how they are connected.

# 1) You should create one R script called run_analysis.R that does the following. 
# 2) Merges the training and the test sets to create one data set. [DONE]
# 3) Extracts only the measurements on the mean and standard deviation for each measurement. [DONE]
# 4) Uses descriptive activity names to name the activities in the data set [DONE]
# 5) Appropriately labels the data set with descriptive variable names. [DONE]
# 6) Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
###

### setup
setwd("/Users/rworden/Coursera2/")
###

### download files initially (run once)
# url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# download.file(url,destfile="runAnalysis.zip",method="curl")
# unzip("runAnalysis.zip")
###

### re: (4), label test and train data with activity descriptions
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
###

### re:(5), label all features in test and train with labels from features.txt
### once this is done, we can merge test->test data and train->train data (subject_*, X_*, y_*)
### and then append/rbind test and train data into one dataframe

# input and process features.txt
# TODO(?) remove commas in label names? meh
featureLabels<-read.table("./UCI HAR Dataset/features.txt")
featureLabels$V1<-NULL
colnames(featureLabels)<-"feature"
#featureLabels$feature<-as.character(featureLabels$feature)
# why does replacing commas break everything and make it not a vector?
# replace "," with "|" because wtf would you put commas in a fieldname
# featureLabels<-gsub("\\,","\\|",featureLabels$feature)
# turn features.txt into character var separated by quotes and commas for use in names()
# holy hell, there is probably a much better way to do this
i<-1
featureLabelsTransform<-character()
for(i in i:nrow(featureLabels)) {
    ## TODO, these "" don't do anything, and moreover, aren't needed. Remove them
    ## Apparently character() handles everything
    featureLabelsTransform<-rbind(featureLabelsTransform,gsub(" ","",(paste("",as.character(featureLabels[i,]),""))))
    i<-i+1
}
# TEST data
# ingest test data
X_test<-read.table("./UCI HAR Dataset/test/X_test.txt")
# label each column in X_test.txt with featureLabels
names(X_test)<-featureLabelsTransform
# TRAIN data
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt")
# label each column in X_test.txt with featureLabels
names(X_train)<-featureLabelsTransform
###

### now, merge merge test->test data and train->train data (subject_*, X_*, y_*)
# yTrain and yTest are ready to go
# X_test and X_train are ready to go
## need to get subject_test and subject_train
subjectTest<-read.table("./UCI HAR Dataset/test/subject_test.txt")
names(subjectTest)<-"subject"
subjectTrain<-read.table("./UCI HAR Dataset/train/subject_train.txt")
names(subjectTrain)<-"subject"
# merge testing data (subjectTest,X_test,yTest) on row number (yikes)
test<-cbind(subjectTest,X_test,yTest)
# merge training data
train<-cbind(subjectTrain,X_train,yTrain)
###

### re:(2), append train and test together
### first add a var in each for where it came from
test$testData<-TRUE
train$testData<-FALSE
# now, append train and test
complete<-rbind(test,train)
###

### Re:(3), need to grep out the colnames (+activity and subject ID) that are means and SD's
## what about columns like "fBodyAccJerk-meanFreq()-Z"? Should that be included or regex'ed out? including for now...
targetCols<-grep("(-mean|-std)",colnames(complete))
# now just get subjectcol, activity columns, and targetColumns:
completeProcessed<-complete[,c(1,563,564,565,targetCols)]
###

### Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## right idea, need subject and description to be columns
# head(tapply(completeProcessed[,5],paste(completeProcessed$V1,completeProcessed$activityDescription),mean))

# loop and cbind for mean and std
testTmp<-NULL
i = 1
for(i in 1:nrow(completeProcessed)) {
    testTmp<-cbind( 
        #### ohh, double loop time. per row and column. gotcha
    aggregate(completeProcessed[i,] ~ completeProcessed$subject + completeProcessed$activityDescription,data=completeProcessed,mean),
    aggregate(completeProcessed[i,] ~ completeProcessed$subject + completeProcessed$activityDescription,data=completeProcessed,sd)
    )
    
    rbind(testTmp,testTmp)
    
    i<-i+1
}

###

