# Capstone_Project

## Objective:
+ Create a machine learning model to correctly predict the class of the network data.
+ Use different preprocessing methods to clean, deduplicate and standardize the data.
+ Explore different types of feature selection algorithms, perform a comparative study to find the most effective feature selection algorithm.
+ Test the model with k-fold cross validation and check for any discrepancies.


## To do list:
| 2-do | importance | details |
| -------- | -------- | -------- |
| Research question   |  1   | All participation needed   |
| Research Objectives   |  1   | All participation needed   |
| Presentation   |  3   | Any takers?   |
| Structure plan  |  1   | tasks coordination   |
| More PREPROCESSING steps   | 2   | Midani's task   |
| Stuff 3   |  10   |  NA  |
| Stuff 4   |  10  |  NA  |


## Questions:
+ how/what 2 visualize such a vast dataset?
+ will there be extra classification/clustering needed for category prediction (as per peer review paper)?
+ regarding NAs, if the Class (targrt variable) is missing, can the sample be useful or should I delete each sample for with missing Class?
+ outliers removal or winsorizing?
+ if we shuffle for computational convenience, would it make it harder for us to visualize the data?
+ the difference between the columns is vast. Does Standardization count for scaling all 42 various features separately? 
+ what if our feature selection remains unclear, and the var names are not understandable, and the figure representation of the feature is vague? Wagwan then?



## Already done:
+ duplicated lines removed
+ vars factored
+ missing values imputed with median 
+ features are renamed properly
+ outliers_less var created (nrow: 173877 after duplicates removable)

