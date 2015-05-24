## This R script processes the required data, tidies it up, and writes the output to a text file.

require(plyr)

filename1 <- "getdata-projectfiles-UCI HAR Dataset.zip";	# This is the name of the .zip file that is downloaded from the given URL

if (file.exists(filename1)) {
unzip(zipfile=filename1) 		# If it already exists, just unzip it

} else { 
					# If it does not already exist, download and unzip it
       fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL,"proj3.zip",method="curl")
        unzip(zip.file="proj3.zip")
        }                           


setwd("UCI HAR Dataset/")		# The unzipped files are present in this directory.

## The following code reads in the training and test files. For each of test and train, there is a subject, X and y file.

TrainSubs <- read.table("train/subject_train.txt",strip.white=TRUE,stringsAsFactors=FALSE,col.names="subject")
TestSubs <- read.table("test/subject_test.txt",strip.white=TRUE,stringsAsFactors=FALSE,col.names="subject")
Testy <- read.table("test/y_test.txt",strip.white=TRUE,stringsAsFactors=FALSE,col.names="label")
TestX <- read.table("test/X_test.txt",strip.white=TRUE,stringsAsFactors=FALSE)
Trainy <- read.table("train/y_train.txt",strip.white=TRUE,stringsAsFactors=FALSE,col.names="label")
TrainX <- read.table("train/X_train.txt",strip.white=TRUE,stringsAsFactors=FALSE)

#######################################################################################################################################
## 1. Here, I begin merging the training and test data sets
#######################################################################################################################################

## The following two steps merge the 3 files for each of test and train (by columns)
Test_Master <- cbind(TrainX,Trainy,TrainSubs)
Train_Master <- cbind(TrainX,Trainy,TrainSubs)

## The following command merges the two data set (by the rows)
DataM <-rbind(Train_Master,Test_Master)

#######################################################################################################################################
## 2. I appropriately label the data set with descriptive variable names
#######################################################################################################################################

## The following file contains the names of the features recorded in the files above
features <- read.table("features.txt", strip.white=TRUE, stringsAsFactors=FALSE)

## I assign the feature names appropriately to the column names of the merged dataset
colnames(DataM)[1:561] <- features$V2

## This command removes parentheses from the names to tidy them up
names(DataM) <- gsub('\\(|\\)',"",names(DataM), perl = TRUE)

## This command makes syntactically valid names to further tidy them up
names(DataM) <- make.names(names(DataM))

#######################################################################################################################################
## 3. I use descriptive activity names to name the activities in the data set
#######################################################################################################################################

## label the activity names  correctly according to their names coded in the following file
labels <- read.table("activity_labels.txt", stringsAsFactors=FALSE)

## To do a join, I make sure the relevant columns in the labels table and the merged dataset have the same name, "label"
colnames(labels)[2] <- "label"

## I then perform the join, thus renaming the activities correctly by their proper name
 DataM <- join(DataM, labels,by="label")
dimk1 <- dim(DataM)
colnames(DataM)[dimk1[2]] <- "activity_name" 

#######################################################################################################################################
## 3. I extract only the measurements on teh mean and standard deviation for each measurement
#######################################################################################################################################

## As we are only interested in columns with mean and standard deviations, this command gets a list of all the variables 
## that are means or standard deviations
SubID <- grep("mean\\(\\)|std\\(\\)", features$V2)

## I now subset out the dataset of means and standard deviations. However, I make sure to add back the label, subject and activity name info
DataMeanStd <- DataM[SubID]
DataMeanStd$label <- DataM$label
DataMeanStd$subject <- DataM$subject
DataMeanStd$activity_name <- DataM$activity_name

#######################################################################################################################################
# Now I create a second, independent tidy data set, Data_MS_Avg, with the average of each variable for each activity and each subject.
#######################################################################################################################################

Data_MS_Avg = ddply(DataMeanStd, c("subject","activity_name"), numcolwise(mean))
## I write it out to a text file, as required.
write.table(Data_MS_Avg, file = "tidy_data_set.txt",row.name=FALSE)
