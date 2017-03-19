### Introduction

This repo contains three components:
* `README.md` - this file

* `run_analysis.R` - script that processes input data and creates a tidy dataset (see ‘Script Description’ for details)
To run this script successfully, the working directory must be 'UCI HAR Dataset', which is the directory created when the original dataset archive iz unzipped and contains subdirectories 'test/' and 'train/'.
This script outputs the file `TidyDataSet.txt`, which is submitted separately, as per the assignment instructions.
"TidyDataSet.txt" contains tidy data in the wide format, were each column contains corresponds to a single variable, either subject ID (30 unique values), activity (6 unique values), or features whose original names contain expressions ‘std’ and ‘mean’ (81)
See section “Assumptions” below for further explanation.

* `CodeBook.md`, which describes the contents of `TidyDataSet.txt` (e.g. variables, summaries, etc.) and transformations that have been performed to clean up data

### Script Description
NOTE: script must be run in the directory that contains raw data files, such as "UCI HAR Dataset", which is created by unzipping the archive
- loads relevant packages (plyr, dplyr, library)
- reads dataset files into R objects:
- activity labels (6 entries)
  feature list (561)
  TRAINING set (7352 entries for 21 subjects and their activities - multiple measurements/calculations of each of 561 features)
  TEST set (2947 entries for 9 subjects and their activities - multiple measurements/calculations of each of 561 features)
- labels training/test datasets with descriptive feature names (resolves duplicate names into unique ones) – `Assignment Step 4`
- adds subject IDs and descriptive activity names to training/test datasets -  `Assignment Step 3`
- merges training and test sets (10299 records) – `Assignment Step 1`
- extracts 81 features on mean and SD for each measurement (see ‘Assumptions’ for further explanation) – `Assignment Step 2`
- creates final descriptive feature names by further processing the labels
- calculates mean of individual measurements for each one of the 40 subject-activity combinations that exist in the dataset and each one of the 81 selected features - `Assignment Step 5`
- merges the table of calculated means for existing subject-activity combinations with the list of the 180 (30 x 6) possible subject-activity combinations, inserting NA where data is missing - `Assignment Step 5`
- writes the tidy data set (180 rows x 81 columns) into a text file

### Assumptions
Since this is an open-ended assignment, certain choices were made:
- order of analysis steps was changed
- variables selected as “measurements on mean and SD” are the 88 variables that contain expressions ‘mean()’ and ‘std()’ at the end, or ‘mean’  anywhere in the name, minus the 7 variables that contain word ‘angle’, to yield 81 final variables
- descriptive names of chosen variables were constructed based on original variable names and the explanation of their origin, as provided by the raw dataset authors
- tidy data is presented in the wide format (instead of narrow/long), i.e. a single table whose each row contains the values of all variables for a single subject-activity combination
