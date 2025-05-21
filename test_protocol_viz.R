# Test script for protocol-based visualizations
# This script will test the visualizations without knitting the entire RMD file

# Load required libraries
library(data.table)
library(plotly)
library(RColorBrewer)

# Check if data exists, otherwise load it
if (!exists("data")) {
  if (file.exists("data.csv")) {
    data <- fread("data.csv")
    # Ensure proper column names and factor conversion
    if (ncol(data) >= 42) {
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
      data$class <- as.factor(data$class)
      data$protocol_type <- as.factor(data$protocol_type)
      data$service <- as.factor(data$service)
      data$flag <- as.factor(data$flag)
    }
  } else {
    # Create a sample dataset for testing if data.csv is not available
    cat("Data file not found. Creating a sample dataset for testing.\n")
    set.seed(123)
    data <- data.frame(
      duration = runif(1000, 0, 100),
      protocol_type = sample(c("tcp", "udp", "icmp"), 1000, replace = TRUE),
      service = sample(c("http", "ftp", "smtp", "dns"), 1000, replace = TRUE),
      flag = sample(c("SF", "REJ", "S0"), 1000, replace = TRUE),
      src_bytes = rpois(1000, 1000),
      dst_bytes = rpois(1000, 500),
      class = sample(c("normal", "neptune", "smurf"), 1000, replace = TRUE)
    )
    # Convert to factors
    data$protocol_type <- as.factor(data$protocol_type)
    data$service <- as.factor(data$service)
    data$flag <- as.factor(data$flag)
    data$class <- as.factor(data$class)
  }
}

# Split data by protocol type
protocols <- unique(as.character(data$protocol_type))
protocols <- protocols[!is.na(protocols) & protocols != ""]

cat("Available protocols:", paste(protocols, collapse = ", "), "\n")

# Create a list to store the protocol-specific datasets
protocol_data <- list()

# Split the data with error handling
for (protocol in protocols) {
  subset_data <- data[data$protocol_type == protocol, ]
  if (nrow(subset_data) > 0) {
    protocol_data[[protocol]] <- subset_data
    cat("Protocol", protocol, "has", nrow(protocol_data[[protocol]]), "samples\n")
  } else {
    cat("Protocol", protocol, "has no samples, skipping...\n")
  }
}

# Test TCP visualizations
if ("tcp" %in% names(protocol_data) && nrow(protocol_data[['tcp']]) > 0) {
  tcp_data <- protocol_data[['tcp']]
  
  cat("\n### TCP Protocol Analysis", "\n")
  cat("Number of TCP connections:", nrow(tcp_data), "\n")
  cat("Number of attack types in TCP:", length(unique(tcp_data$class)), "\n\n")
  
  # 1. Attack Distribution in TCP - More informative with percentages
  tcp_class_counts <- table(tcp_data$class)
  tcp_class_df <- data.frame(
    Class = names(tcp_class_counts),
    Count = as.numeric(tcp_class_counts),
    Percentage = round(100 * as.numeric(tcp_class_counts) / sum(tcp_class_counts), 2)
  )
  tcp_class_df <- tcp_class_df[order(tcp_class_df$Count, decreasing = TRUE),]
  
  # Print the table for reference
  print(tcp_class_df)
  
  # Create a more informative bar plot
  pdf("tcp_attack_distribution.pdf", width=10, height=6)
  par(mar = c(10, 4, 4, 2) + 0.1)  # Increase bottom margin for labels
  barplot(tcp_class_df$Count, 
          names.arg = paste0(tcp_class_df$Class, "\n(", tcp_class_df$Percentage, "%)"),
          col = rainbow(nrow(tcp_class_df)),
          main = "Attack Type Distribution in TCP Protocol",
          ylab = "Count",
          las = 2,  # Rotate labels
          cex.names = 0.8)  # Smaller text for labels
  dev.off()
  
  # Test service distribution
  top_services <- names(sort(table(tcp_data$service), decreasing = TRUE)[1:min(10, length(unique(tcp_data$service)))])
  service_class_table <- table(tcp_data$service, tcp_data$class)
  top_service_class <- service_class_table[top_services,]
  service_class_df <- as.data.frame.matrix(top_service_class)
  
  # Print the table for reference
  cat("\nTop Services by Attack Type:\n")
  print(service_class_df)
  
  # Create a heatmap
  pdf("tcp_service_heatmap.pdf", width=10, height=6)
  heatmap_colors <- colorRampPalette(c("white", "yellow", "orange", "red"))(100)
  heatmap(as.matrix(service_class_df), 
          col = heatmap_colors,
          main = "Service vs Attack Type Heatmap (TCP)",
          xlab = "Attack Type", 
          ylab = "Service",
          cexRow = 0.8,
          cexCol = 0.8,
          margins = c(10, 10))
  dev.off()
}

# Test UDP visualizations
if ("udp" %in% names(protocol_data) && nrow(protocol_data[['udp']]) > 0) {
  udp_data <- protocol_data[['udp']]
  
  cat("\n### UDP Protocol Analysis", "\n")
  cat("Number of UDP connections:", nrow(udp_data), "\n")
  cat("Number of attack types in UDP:", length(unique(udp_data$class)), "\n\n")
  
  # Create a pie chart for services
  udp_service_counts <- table(udp_data$service)
  udp_service_df <- data.frame(
    Service = names(udp_service_counts),
    Count = as.numeric(udp_service_counts),
    Percentage = round(100 * as.numeric(udp_service_counts) / sum(udp_service_counts), 2)
  )
  udp_service_df <- udp_service_df[order(udp_service_df$Count, decreasing = TRUE),]
  
  # Print the table
  cat("\nService Distribution in UDP:\n")
  print(udp_service_df)
  
  # Create a pie chart
  pdf("udp_service_pie.pdf", width=8, height=8)
  top_n <- min(8, nrow(udp_service_df))
  if (top_n > 0) {
    # Combine small categories into "Other"
    if (nrow(udp_service_df) > top_n) {
      top_services <- udp_service_df[1:top_n,]
      other_services <- data.frame(
        Service = "Other",
        Count = sum(udp_service_df$Count[(top_n+1):nrow(udp_service_df)]),
        Percentage = sum(udp_service_df$Percentage[(top_n+1):nrow(udp_service_df)])
      )
      pie_data <- rbind(top_services, other_services)
    } else {
      pie_data <- udp_service_df
    }
    
    # Create the pie chart
    pie(pie_data$Count, 
        labels = paste0(pie_data$Service, " (", pie_data$Percentage, "%)"),
        col = rainbow(nrow(pie_data)),
        main = "Service Distribution in UDP Protocol")
  }
  dev.off()
}

# Test Cross-Protocol Comparison
if (length(names(protocol_data)) > 0) {
  cat("\n### Cross-Protocol Comparison\n")
  
  # Prepare data frame for attack distribution
  attack_by_protocol <- data.frame(Protocol=character(), 
                                  AttackType=character(), 
                                  Count=numeric(), 
                                  stringsAsFactors=FALSE)
  
  for (protocol in names(protocol_data)) {
    if (nrow(protocol_data[[protocol]]) > 0) {
      # Get class counts for this protocol
      class_counts <- table(protocol_data[[protocol]]$class)
      
      # Filter out any empty class values
      valid_classes <- names(class_counts)[names(class_counts) != ""]
      class_counts <- class_counts[valid_classes]
      
      # Add to data frame
      for (cls in names(class_counts)) {
        if (!is.na(cls) && cls != "") {  # Skip NA or empty class names
          attack_by_protocol <- rbind(
            attack_by_protocol,
            data.frame(
              Protocol = protocol,
              AttackType = cls,
              Count = class_counts[cls],
              stringsAsFactors = FALSE
            )
          )
        }
      }
    }
  }
  
  # Print summary table
  cat("Attack counts by protocol:\n")
  attack_summary <- aggregate(Count ~ Protocol, data = attack_by_protocol, sum)
  print(attack_summary)
  
  # Create a stacked bar plot
  if (nrow(attack_by_protocol) > 0) {
    # Create a contingency table for easier plotting
    attack_table <- xtabs(Count ~ Protocol + AttackType, data = attack_by_protocol)
    
    # Print the table
    cat("\nAttack distribution by protocol:\n")
    print(attack_table)
    
    # Create a stacked barplot
    pdf("protocol_attack_distribution.pdf", width=10, height=6)
    par(mar = c(10, 4, 4, 2) + 0.1)  # Increase bottom margin for labels
    barplot(t(attack_table), 
            col = rainbow(ncol(attack_table)),
            main = "Attack Type Distribution Across Protocols",
            ylab = "Count",
            legend.text = colnames(attack_table),
            args.legend = list(x = "topright", cex = 0.7))
    dev.off()
  }
}

cat("\nTest visualizations completed. Check the PDF files for results.\n")

