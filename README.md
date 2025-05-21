# Capstone_Project

## Objective:
+ Create a machine learning model to correctly predict the class of the network data.
+ Use different preprocessing methods to clean, deduplicate and standardize the data.
+ Explore different types of feature selection algorithms, perform a comparative study to find the most effective feature selection algorithm.
+ Test the model with k-fold cross validation and check for any discrepancies.


## To do list:
| 2-do | importance | details |
| -------- | -------- | -------- |
| Research questions confirmation  |  1   | All participation needed   |
| Research Objectives  confirmation |  1   | All participation needed   |
| “protocol_type == 1” to be deleted because fuck it   | 2   | Hesh's task   |
| “protocol_type ==    ” change the name to “b’Other’”   | 2   | Hesh's task   |
| Feature selection and scaling   | 2   | Midani's task   |
| Structure plan  |  1   | tasks coordination   |



## Questions:
+ how to use azure to visualize our data and/or manipulate it futher?
+ confirming certainty to keep outliers?
+ the difference between the columns is vast. Does Standardization count for scaling all 42 various features separately? 



## Potential research Questions:
+ How effectively can network traffic anomalies be detected using only protocol metadata?
. Focus on protocol_type, service, and flag features
. Evaluate different feature combinations
. Compare with full feature set performance
+ What are the unique behavioral patterns that distinguish different attack types from normal traffic?
. Analyze feature importance per attack type
. Create profile visualizations for each attack class
. Identify minimum feature sets needed to detect each attack type
+ How does the predictive performance of statistical features compare to categorical network attributes in identifying specific attack vectors?
. Compare models using only numeric vs only categorical features
. Evaluate performance on specific attack types
. Analyze feature importance within each category


## Already done:
+ duplicated lines removed
+ vars factored
+ missing values imputed with median 
+ features are renamed properly
+ outliers_less var created (nrow: 173877 after duplicates removable)

## Group Members & Contributions

| Name            | Contributions                           |
|-----------------|-----------------------------------------|
| Abed Midani     | Data understanding and Preperation, Preprocessing (NA,Outlier,Imputing ect.), Documentation, ... |
| Nevin Joseph    | Data understanding (also refering to research paper), Handling class imbalance (data leakage), Creation & Evaluation of Machine Learning Models|
| Heshan Raj      | Research questions, sleeping     |


