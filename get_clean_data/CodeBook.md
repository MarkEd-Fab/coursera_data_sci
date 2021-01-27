
# Getting and Cleaning Data Course Project Code Book

### Background

This document will run you through the steps performed to satisfy the following course requirements.  

Using this [dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), R code should be written to:  

1. Merge the training and the test sets to create one data set  
2. Extract only the measurements on the mean and standard deviation for each measurement  
3. Use descriptive activity names to name the activities in the data set  
4. Appropriately labels the data set with descriptive variable names  
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject  


The raw R code can be found on `run_analysis.R`


### Preparation Step

Inside the repository, I've created a sub folder where I downloaded the data to,  
named `"./get_clean_data"`, and thus final directory `"./get_clean_data/UCI HAR Dataset"`  

```{r}
library(dplyr)

##Dowload Dataset File
filepath <- "C:/Users/u957797/Documents/R/myRHome/coursera_data_sci/get_clean_data/"
download.file(url ="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile = paste0(filepath, "data.zip"))

unzip(paste0(filepath, "data.zip"), exdir = filepath)

```




### Merging Files

In this step, the following were set up:

1. `activ_lbl`: contains activity name information
2. `ftrs_var` : contains response variable names
3. `df_all` : merged train and test data sets, wherein *Subject_ID* is the  
descriptive variable name for test subjects and *Activity_Name* is the  
descriptive variable name for activities.
```{r}
##Read Files
#Activity labels
activ_lbl <- read.table("./get_clean_data/UCI HAR Dataset/activity_labels.txt",
                        header = F)
#Variable names
ftrs_var <- read.table("./get_clean_data/UCI HAR Dataset/features.txt",
                       header = F)

#Set up for reading test and train data files
dat_dir <- "./get_clean_data/UCI HAR Dataset/"
sub_dir <- c("test", "train")
df_all <- NULL

#Loop over test and train folder, wherein for each loop, all the files are read
#and merged. Lastly, both test and train data sets are merged
for(i in 1:length(sub_dir)) {
      flnm <- list.files(path = paste0(dat_dir, sub_dir[i]),
                         pattern = "+\\.txt$", recursive = F)
      
      df <- setNames(object = do.call(cbind, lapply(X = flnm, FUN = function(x){
            read.csv(file = paste0(dat_dir, sub_dir[i], "/", x), header = F,
                     sep = "")})), nm = c("Subject_ID", ftrs_var[[2]], "Activity_Code"))
      
      df <- merge(x = df, y = activ_lbl, by.x = "Activity_Code", by.y = "V1")
      
      df$Activity_Name <- df$V2
      
      df$V2 <- NULL
      
      df_all <- do.call(rbind, list(df_all, df))
}

```




### Extracting Mean and Standard Deviation Measurements
```{r}
#Select Mean and Standard Deviation Variables
df_all_sel <- df_all %>%
      dplyr::select(Subject_ID, Activity_Name,
                    grep(pattern = ".*mean\\(\\).*|.*std\\(\\).*",
                         x = ftrs_var[[2]], value = T)) %>% 
      mutate(Subject_ID = paste0("Subject_", Subject_ID))

```




### Rename Variables with Descriptive Names

```{r}
#Use Descriptive Names for selected Variables
names(df_all_sel) <- gsub(pattern = "^t", replacement = "Time",
                          x = names(df_all_sel))
names(df_all_sel) <- gsub(pattern = "^f", replacement = "Frequency",
                          x = names(df_all_sel))
names(df_all_sel) <- gsub(pattern = "Acc", replacement = "Accelerometer",
                          x = names(df_all_sel))
names(df_all_sel) <- gsub(pattern = "Gyro", replacement = "Gyroscope",
                          x = names(df_all_sel))
names(df_all_sel) <- gsub(pattern = "Mag", replacement = "Magnitude",
                          x = names(df_all_sel))
names(df_all_sel) <- gsub(pattern = "-mean\\(\\)", replacement = "Mean",
                          x = names(df_all_sel))
names(df_all_sel) <- gsub(pattern = "-std\\(\\)", replacement = "StDev",
                          x = names(df_all_sel))
names(df_all_sel) <- gsub(pattern = "BodyBody", replacement = "Body",
                          x = names(df_all_sel))

```




### Summarise Data and Export to a File

Lastly, the data set was summarized by the averaging each variable for each activity and each subject.  
This summary data is exported to a `""./get_clean_data/Get_Clean_Final_Data.txt"`.  

```{r}
#Calculate means of selected response variables by subject and activity
df_summary <- df_all_sel %>%
      group_by(Subject_ID, Activity_Name) %>% 
      summarise_all(list(mean))


#Write to File
write.table(x = df_summary, file = "./get_clean_data/Get_Clean_Final_Data.txt")
```


