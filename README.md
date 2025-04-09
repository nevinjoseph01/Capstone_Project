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

## Potential research Questions:
+ Are certain types of network traffic more commonly associated with anomalies or attacks? Exploring protocol, service, and flag distributions in relation to anomalies.

+ How do normal and anomalous connections differ in terms of volume and duration? Comparing bytes sent/received and connection times.

+ Do specific connection behaviors appear more frequently in anomalies? Looking at patterns like repeated login attempts or unusual connection flags.

+ Are there patterns in how network activity builds up before an anomaly occurs? Investigating features like connection count or repeated service usage.

+ Do host-based behaviors show early signs of risky or unusual activity? Analyzing metrics like access rate, host diversity, or repeated service targeting.

+ Can we identify distinct behavior profiles associated with different types of anomalies? Looking for clusters or patterns that map to known threat categories.

+ Are there silent or low-visibility behaviors that still represent a high level of risk? Studying low-volume, low-activity traffic that results in serious anomalies.


## Already done:
+ duplicated lines removed
+ vars factored
+ missing values imputed with median 
+ features are renamed properly
+ outliers_less var created (nrow: 173877 after duplicates removable)

