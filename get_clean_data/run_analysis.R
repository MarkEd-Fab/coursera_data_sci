library(dplyr)

##Under this repository, I created a sub-folder ("./get_clean_data") specific for
##this course assignment, as I intend to use this same repo for other future
##Coursera Programming Assignment

##Dowload Dataset File
download.file(url ="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile = "./get_clean_data/data.zip")

unzip("./get_clean_data/data.zip", exdir = "./get_clean_data")

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
#and merged. Lastly, both test and train datasets are merged
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


#Select Mean and Standard Deviation Variables
df_all_sel <- df_all %>%
      dplyr::select(Subject_ID, Activity_Name,
                    grep(pattern = ".*mean\\(\\).*|.*std\\(\\).*",
                         x = ftrs_var[[2]], value = T)) %>% 
      mutate(Subject_ID = paste0("Subject_", Subject_ID))


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


#Calculate means of selected response variables by subject and activity
df_summary <- df_all_sel %>%
      group_by(Subject_ID, Activity_Name) %>% 
      summarise_all(list(mean))


#Write to File
write.table(x = df_summary, file = "./get_clean_data/Get_Clean_Final_Data.txt")