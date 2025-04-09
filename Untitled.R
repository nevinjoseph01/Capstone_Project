if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

# Load libraries ---------------------------------------------------------------
# Create our function "using()" 
using <- \(pkg) {
  # if a package is not installed, install it
  if (!rlang::is_installed(pkg)) {
    install.packages(pkg, repo = "https://cloud.r-project.org")}# load the package
  library(pkg, character.only = TRUE)
}



using("data.table") # The data manipulation king
using("caret") # The ML swiss-knife - http://topepo.github.io/caret/available-models.html
using("plotly") # Beautiful interactive plots
using("ranger") # the fastest and better random forest implementation
using("adabag") # Adaboost.    
using("xgboost") # Extreme Gradient boosting
using("imbalance") # Oversampling
using("ROSE") # Synthetic generation of new data to rebalance
using("VIM")



data <- fread("data.csv")
str(data)

View(data)
any(is.na(data)) # 
colSums(is.na(data)) #

sum(complete.cases(data))
# 22469
nrow(data)
# 528603

# checking for duplicates:
sum(duplicated(data))
nrow(data) - sum(duplicated(data))# 399668
#remove duplicates
data <- data[!duplicated(data), ]

colnames(data)[1:42] <- c(
  "duration", "protocol_type", "service", "flag", "src_bytes", "dst_bytes",
  "land", "wrong_fragt", "urgent", "hot", "num_fail_login", "logged_in",
  "nu_comprom", "root_shell", "su_attempted", "num_root", "nu_file_creat",
  "nu_shells", "nu_access_files", "nu_out_cmd", "is_host_login",
  "is_guest_login", "count", "srv_count", "serror_rate", "srv_serror_rate",
  "rerror_rate", "srv_rerror_rate", "same_srv_rate", "diff_srv_rate",
  "srv_diff_h_rate", "host_count", "host_srv_count", "h_same_sr_rate",
  "h_diff_srv_rate", "h_src_port_rate", "h_srv_d_h_rate", "h_serror_rate",
  "h_sr_serror_rate", "h_rerror_rate", "h_sr_rerror_rate","class"
)
#colnames(data)[42] <- "class"
data.frame(names(data))

View(data)

data$class <- as.factor(data$class)
data$protocol_type <- as.factor(data$protocol_type)
data$service <- as.factor(data$service)
data$flag <- as.factor(data$flag)

data[data$class == "", ] |> head(10)

#imputing:
for (j in names(data)) {
  if(is.numeric(data[[j]])) {
    data[is.na(get(j)), (j) := median(data[[j]], na.rm = TRUE)]}} # fucking median imputation values is done now 

nrow(data)
View(data)


# removing outliers:
training_without_outliers <- copy(data)
numeric_cols <- names(data)[sapply(data, is.numeric)]
for(i in numeric_cols) { 
  for(j in unique(data$class)) {
    values <- data[class == j, get(i)]
    Q1 <- quantile(values, 0.25)
    Q3 <- quantile(values, 0.75)
    IQR <- Q3 - Q1
    lower_bound <- Q1 - 1.5 * IQR
    upper_bound <- Q3 + 1.5 * IQR
    training_without_outliers <- training_without_outliers[!(
      class == j & (get(i) < lower_bound | get(i) > upper_bound))]}}

nrow(training_without_outliers)/nrow(data)
# 0.4350536





# nrow of the original data with duplicates
nrow(fread("data.csv"))
# 528603

# nrow of the original data without duplicates
nrow(data)
# 399668

nrow(training_without_outliers)
# 173877


