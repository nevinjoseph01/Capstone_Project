library(data.table)
library(plotly)
library(dplyr)
library(ggplot2)

# Load data
data <- fread("data.csv")

# Rename columns as in your capstone.rmd
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

# Remove rows with empty class
data <- data[class != ""]

# Get unique protocol types
protocol_types <- unique(data$protocol_type)
print(protocol_types)

# Create subsets by protocol type
protocol_subsets <- list()
for(p_type in protocol_types) {
  protocol_subsets[[p_type]] <- data[protocol_type == p_type]
}

# ---- VISUALIZATION 1: ATTACK DISTRIBUTION BY PROTOCOL ----
# Prepare data for attack types by protocol
attack_by_protocol <- data %>%
  group_by(protocol_type, class) %>%
  summarize(count = n(), .groups = 'drop') %>%
  arrange(protocol_type, desc(count))

# Create interactive bar chart
attack_dist_plot <- plot_ly(data = attack_by_protocol, 
                            x = ~class, 
                            y = ~count, 
                            color = ~protocol_type, 
                            type = "bar") %>%
  layout(title = "Attack Distribution by Protocol Type",
         xaxis = list(title = "Attack Type", tickangle = 45),
         yaxis = list(title = "Count", type = "log"),
         barmode = "group")

# Save plot
htmlwidgets::saveWidget(attack_dist_plot, "plots/attack_distribution_by_protocol.html")
print("Attack distribution by protocol plot saved")

# ---- VISUALIZATION 2: SOURCE VS DESTINATION BYTES BY PROTOCOL ----
# Create scatter plots for each protocol
src_dst_plots <- lapply(protocol_types, function(p_type) {
  subset_data <- protocol_subsets[[p_type]]
  
  # Filter outliers for better visualization
  q99_src <- quantile(subset_data$src_bytes, 0.99)
  q99_dst <- quantile(subset_data$dst_bytes, 0.99)
  
  filtered_data <- subset_data[src_bytes <= q99_src & dst_bytes <= q99_dst]
  
  plot_ly(data = filtered_data, 
          x = ~src_bytes, 
          y = ~dst_bytes, 
          color = ~class,
          type = "scatter", 
          mode = "markers",
          marker = list(opacity = 0.7),
          hoverinfo = "text",
          text = ~paste("Class:", class,
                       "<br>Src bytes:", src_bytes,
                       "<br>Dst bytes:", dst_bytes)) %>%
    layout(title = paste("Source vs Destination Bytes -", p_type, "Protocol"),
           xaxis = list(title = "Source Bytes"),
           yaxis = list(title = "Destination Bytes"))
})

# Save plots
for(i in seq_along(protocol_types)) {
  htmlwidgets::saveWidget(src_dst_plots[[i]], 
                         paste0("plots/src_dst_bytes_", protocol_types[i], ".html"))
}
print("Source vs Destination bytes plots saved")

# ---- VISUALIZATION 3: SERVICE DISTRIBUTION BY PROTOCOL ----
# Create bar charts for service distribution within each protocol
service_dist_plots <- lapply(protocol_types, function(p_type) {
  subset_data <- protocol_subsets[[p_type]]
  
  # Get top services by frequency
  service_counts <- subset_data[, .N, by = service][order(-N)][1:20]
  
  plot_ly(data = service_counts, 
          x = ~service, 
          y = ~N, 
          type = "bar",
          marker = list(color = ~N, colorscale = "Viridis")) %>%
    layout(title = paste("Top Services -", p_type, "Protocol"),
           xaxis = list(title = "Service", tickangle = 45),
           yaxis = list(title = "Count"))
})

# Save plots
for(i in seq_along(protocol_types)) {
  htmlwidgets::saveWidget(service_dist_plots[[i]], 
                         paste0("plots/service_dist_", protocol_types[i], ".html"))
}
print("Service distribution plots saved")

# ---- VISUALIZATION 4: DURATION ANALYSIS BY PROTOCOL AND CLASS ----
# Create violin plots for connection duration by protocol and class
duration_plots <- lapply(protocol_types, function(p_type) {
  subset_data <- protocol_subsets[[p_type]]
  
  # Filter outliers
  q99_duration <- quantile(subset_data$duration, 0.99)
  filtered_data <- subset_data[duration <= q99_duration]
  
  # Get top classes for this protocol
  top_classes <- filtered_data[, .N, by = class][order(-N)][1:10]$class
  plot_data <- filtered_data[class %in% top_classes]
  
  plot_ly(data = plot_data, 
          x = ~class, 
          y = ~duration, 
          type = "violin", 
          box = list(visible = TRUE),
          meanline = list(visible = TRUE),
          color = ~class) %>%
    layout(title = paste("Connection Duration by Attack Class -", p_type, "Protocol"),
           xaxis = list(title = "Attack Class"),
           yaxis = list(title = "Duration (seconds)"))
})

# Save plots
for(i in seq_along(protocol_types)) {
  htmlwidgets::saveWidget(duration_plots[[i]], 
                         paste0("plots/duration_analysis_", protocol_types[i], ".html"))
}
print("Duration analysis plots saved")

# ---- VISUALIZATION 5: ERROR RATE ANALYSIS BY PROTOCOL ----
# Create heatmaps of error rates by protocol
error_rate_plots <- lapply(protocol_types, function(p_type) {
  subset_data <- protocol_subsets[[p_type]]
  
  # Select top classes
  top_classes <- subset_data[, .N, by = class][order(-N)][1:10]$class
  plot_data <- subset_data[class %in% top_classes]
  
  # Calculate mean error rates by class
  error_rates <- plot_data[, .(
    serror_rate = mean(serror_rate),
    srv_serror_rate = mean(srv_serror_rate),
    rerror_rate = mean(rerror_rate),
    srv_rerror_rate = mean(srv_rerror_rate),
    h_serror_rate = mean(h_serror_rate),
    h_sr_serror_rate = mean(h_sr_serror_rate),
    h_rerror_rate = mean(h_rerror_rate),
    h_sr_rerror_rate = mean(h_sr_rerror_rate)
  ), by = class]
  
  # Convert to long format for heatmap
  error_rates_long <- melt(error_rates, id.vars = "class", 
                          variable.name = "Error_Type", 
                          value.name = "Rate")
  
  plot_ly(data = error_rates_long, 
          x = ~Error_Type, 
          y = ~class, 
          z = ~Rate, 
          type = "heatmap",
          colorscale = "YlOrRd") %>%
    layout(title = paste("Error Rate Analysis -", p_type, "Protocol"),
           xaxis = list(title = "Error Rate Type"),
           yaxis = list(title = "Attack Class"))
})

# Save plots
for(i in seq_along(protocol_types)) {
  htmlwidgets::saveWidget(error_rate_plots[[i]], 
                         paste0("plots/error_rates_", protocol_types[i], ".html"))
}
print("Error rate analysis plots saved")

# ---- VISUALIZATION 6: HOST ACTIVITY METRICS BY PROTOCOL ----
# Create radar charts for host activity metrics
host_activity_plots <- lapply(protocol_types, function(p_type) {
  subset_data <- protocol_subsets[[p_type]]
  
  # Select top classes
  top_classes <- subset_data[, .N, by = class][order(-N)][1:5]$class
  plot_data <- subset_data[class %in% top_classes]
  
  # Calculate mean host metrics by class
  host_metrics <- plot_data[, .(
    host_count = mean(host_count),
    host_srv_count = mean(host_srv_count),
    h_same_sr_rate = mean(h_same_sr_rate),
    h_diff_srv_rate = mean(h_diff_srv_rate),
    h_src_port_rate = mean(h_src_port_rate),
    h_srv_d_h_rate = mean(h_srv_d_h_rate)
  ), by = class]
  
  # Create radar chart data
  radar_data <- list()
  for(i in seq_along(host_metrics$class)) {
    radar_data[[i]] <- list(
      type = 'scatterpolar',
      r = as.numeric(host_metrics[i, 2:ncol(host_metrics)]),
      theta = names(host_metrics)[2:ncol(host_metrics)],
      fill = 'toself',
      name = host_metrics$class[i]
    )
  }
  
  # Create plot
  plot_ly() %>%
    add_trace(radar_data[[1]]) %>%
    add_trace(radar_data[[2]]) %>%
    add_trace(radar_data[[3]]) %>%
    add_trace(radar_data[[4]]) %>%
    add_trace(radar_data[[5]]) %>%
    layout(
      polar = list(
        radialaxis = list(
          visible = TRUE,
          range = c(0, 1)
        )
      ),
      title = paste("Host Activity Metrics -", p_type, "Protocol")
    )
})

# Save plots
for(i in seq_along(protocol_types)) {
  htmlwidgets::saveWidget(host_activity_plots[[i]], 
                         paste0("plots/host_activity_", protocol_types[i], ".html"))
}
print("Host activity plots saved")

# ---- VISUALIZATION 7: PCA ANALYSIS BY PROTOCOL ----
# Create PCA visualization for numeric variables
pca_plots <- lapply(protocol_types, function(p_type) {
  subset_data <- protocol_subsets[[p_type]]
  
  # Select numeric columns
  numeric_cols <- sapply(subset_data, is.numeric)
  numeric_data <- subset_data[, .SD, .SDcols = numeric_cols]
  
  # Remove constants and handle NAs
  numeric_data <- numeric_data[, .SD, .SDcols = sapply(numeric_data, function(x) var(x, na.rm = TRUE) > 0)]
  numeric_data <- na.omit(numeric_data)
  
  # Sample data if too large
  if(nrow(numeric_data) > 5000) {
    set.seed(123)
    numeric_data <- numeric_data[sample(1:nrow(numeric_data), 5000)]
  }
  
  # Remove class column for PCA
  class_col <- numeric_data$class
  numeric_data$class <- NULL
  
  # Perform PCA
  pca_result <- prcomp(numeric_data, scale. = TRUE)
  pc_data <- as.data.table(pca_result$x[, 1:3])
  pc_data$class <- class_col
  
  # Create 3D scatter plot
  plot_ly(data = pc_data, 
          x = ~PC1, 
          y = ~PC2, 
          z = ~PC3, 
          color = ~class,
          type = "scatter3d", 
          mode = "markers",
          marker = list(size = 3, opacity = 0.7)) %>%
    layout(title = paste("PCA Analysis -", p_type, "Protocol"),
           scene = list(
             xaxis = list(title = "PC1"),
             yaxis = list(title = "PC2"),
             zaxis = list(title = "PC3")
           ))
})

# Save plots
for(i in seq_along(protocol_types)) {
  htmlwidgets::saveWidget(pca_plots[[i]], 
                         paste0("plots/pca_analysis_", protocol_types[i], ".html"))
}
print("PCA analysis plots saved")

# Create directory to save plots if it doesn't exist
if(!dir.exists("plots")) {
  dir.create("plots")
}

print("All visualizations have been created!")
