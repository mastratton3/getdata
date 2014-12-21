#Read in x Train Data in 7352 x 561 dataframe
path <- "train/X_train.txt"
xtrain <- read.table(path)

#Read in the activity types
path <- "features.txt"
features <- read.table(path)
titles <- features[,2]

#Use the features files to set the names of the data frame
colnames(xtrain) <- titles

#Read in the subjects
path <- "train/subject_train.txt"
subjects <- read.table(path, colClasses=c("factor"),col.names = c("Subject"))
#colnames(subjects) <- c("Subject")

#Read in the activities
path <- "train/Y_train.txt"
ytrain <- read.table(path, colClasses=c("factor"), col.names=c("actid"))

#Combine subjects and activity ids
subjectactivity <- cbind(subjects, ytrain)

#Bind the full data set onto the subjects and activities
traindata <- cbind(subjectactivity, xtrain)

#####Repeat Process For Test Data To Do a Simple RBIND######
#Read in x Test Data in ???? x 561 dataframe
path <- "test/X_test.txt"
xtest <- read.table(path)

#Read in the activity types
path <- "features.txt"
features <- read.table(path)
titles <- features[,2]

#Use the features files to set the names of the data frame
colnames(xtest) <- titles

#Read in the subjects
path <- "test/subject_test.txt"
subjects <- read.table(path, colClasses=c("factor"),col.names = c("Subject"))
#colnames(subjects) <- c("Subject")

#Read in the activities
path <- "test/Y_test.txt"
ytest <- read.table(path, colClasses=c("factor"), col.names=c("actid"))

#Combine subjects and activity labels
subjectactivity <- cbind(subjects, ytest)

#Bind the full data set onto the subjects and activities
testdata <- cbind(subjectactivity, xtest)
#colnames(testdata)[2] <- "Activity"

##Both Train and Test Data Should be good..... Time to Rbind!
completedata <- rbind(traindata, testdata)

##Free Memory
#rm(features, path, subjectactivity, subjects, testdata, titles, traindata, xtest, xtrain, ytest, ytrain)

##Remove unneccesary columns to have only mean and std dev
colnames <- colnames(completedata)
means <- grepl("mean()", colnames, fixed=TRUE) #Finding columns with mean()
stds <- grepl("std()", colnames, fixed=TRUE) #Finding columns with std()
meanstd <- means+stds

##Note- I made the decision to only include mean() and not all columns that contained the term mean...
## I did this as there were other columns such as meanFreq() but I interpreted the directions to only include mean() and std() of the actual measurements

meanstd[1:2] <- TRUE #Set the activity and subject to TRUE
meanstd <- as.logical(meanstd) #convert meanstd back from numeric to logical

completedata <- completedata[, meanstd] #Subset to only the subject, activity, mean(), and std()

##Attempt to merge the activity names with the activities

#Read in the activity labels
path <- "activity_labels.txt"
actlabels <- read.table(path, col.names=c("actid","Activity"), colClasses=c("factor", "factor"))

#Merge numbers to names
completedata <- merge(completedata, actlabels, by="actid")

#Rearrange data to be in the order I would like
completedata$actid <- NULL
completedata<-completedata[,c(1,68,2:67)]

####

#Write the original data to a file
write.table(completedata, "smartphonedata.txt", row.names=FALSE)

##Use Aggregate Function to generate mean of each measurement... 
##FYI complete data has 68 cols, 3:68 are measurements and 1:2 are factors
dataaverages <- aggregate(completedata[,3:68], list(completedata$Subject, completedata$Activity),mean)

##Rename the column names
colnames(dataaverages)[1:2] <- c("Subject", "Activity")

##Write the summarized data to a file
write.table(dataaverages, "smartphonesummary.txt", row.names=FALSE)
