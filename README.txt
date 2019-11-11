==================================================================
Human Activity Recognition Using Smartphones Dataset
Version 1.0
Modified by Jeffrey S. Dean to reflect run_analysis.R script actions
==================================================================
Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
Smartlab - Non Linear Complex Systems Laboratory
DITEN - Università degli Studi di Genova.
Via Opera Pia 11A, I-16145, Genoa, Italy.
activityrecognition@smartlab.ws
www.smartlab.ws
==================================================================

The experiments generating the original data sets were carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, 3-axial linear acceleration and 3-axial angular velocity was captured at a constant rate of 50Hz. The obtained dataset was been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

For each record it is provided:
======================================

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

The dataset includes the following files:
=========================================

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector. 

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 


Modifications to data set for Coursera Getting and Cleaning Data Course Project
===============================================================================
The data set described above was modified/transformed in the following ways:

- For each train/test file pair, the data was combined.  For example, the data in the X_train/X_test data sets were merged to create an X_combo data set.

- The X_combo (combined X_train/X_test) data set columns were labeled using the 561 feature names, and a subset of the data containing only the mean and standard deviation based features extracted (named filtered_cols).

- A new column was inserted into each combined data set (excluding the y and subject data sets) representing the type of activity associated with each observation (row of data).  Labels in the activity column for each row were one of the following: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING or LAYING.

- The columns of measured values in the Inertial Signals data sets were labeled based on the data type (body_acc_x|y|z, body_gyro_x|y|z, or total_acc_x|y|z), and the relative sample times of the column values as compared to the initial sample time for each row.  For example, body_acc_x_2.00 is the label of the 100th numeric values column (100 x 0.02 sec) in the body_acc_x_combo data set.

- The Inertial Signal data sets were merged, a subject code column inserted (designating the subject associated with each row of data) and the mean of each variable for each per subject & activity combination was determined.  The resulting table was labeled data_means.

- The subject code column was inserted into the X_combo data set, and the mean of each variable for each per subject & activity combination was determined.  The resulting table was labeled featured_means.

Each data set modified or generated by the script is stored as a *.Rda file in the results directory, under the base (UCI HAR Dataset) directory.


