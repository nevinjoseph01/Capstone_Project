library(ggplot2)
library(RColorBrewer)
library(data.table)

# Function to create attack type distribution by protocol
create_attack_by_protocol_plot <- function(data) {
  # Create a data frame of attack types by protocol
  attack_by_protocol <- data.frame()
  
  for (protocol in unique(data$protocol_type)) {
    # Skip if protocol is NA or empty
    if (is.na(protocol) || protocol == "") next
    
    # Get protocol data
    protocol_subset <- data[data$protocol_type == protocol, ]
    
    # Skip if empty
    if (nrow(protocol_subset) == 0) next
    
    # Count attack types
    attack_counts <- table(protocol_subset$class)
    
    # Calculate percentages
    attack_percentages <- 100 * attack_counts / sum(attack_counts)
    
    # Add to data frame
    for (attack in names(attack_counts)) {
      attack_by_protocol <- rbind(
        attack_by_protocol,
        data.frame(
          Protocol = protocol,
          AttackType = attack,
          Count = attack_counts[attack],
          Percentage = attack_percentages[attack],
          stringsAsFactors = FALSE
        )
      )
    }
  }
  
  # Create a stacked bar chart showing percentages
  p <- ggplot(attack_by_protocol, aes(x = Protocol, y = Percentage, fill = AttackType)) +
    geom_bar(stat = "identity") +
    theme_minimal() +
    labs(
      title = "Attack Type Distribution by Protocol",
      x = "Protocol",
      y = "Percentage",
      fill = "Attack Type"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_brewer(palette = "Set3")
  
  return(p)
}

# Function to create feature importance by protocol
create_feature_importance_by_protocol <- function(data, ranger_fn) {
  # Create a list to store importance data frames
  importance_by_protocol <- list()
  
  # Get feature importance for each protocol
  for (protocol in unique(data$protocol_type)) {
    # Skip if protocol is NA or empty
    if (is.na(protocol) || protocol == "") next
    
    # Get protocol data
    protocol_subset <- data[data$protocol_type == protocol, ]
    
    # Skip if too few samples
    if (nrow(protocol_subset) < 100) {
      cat("Skipping protocol", protocol, "due to insufficient samples.\n")
      next
    }
    
    # Add random feature for baseline
    set.seed(123)
    protocol_subset[, random := runif(nrow(protocol_subset), 1, 100)]
    
    # Train a quick random forest for feature importance
    tryCatch({
      protocol_model <- ranger_fn(
        formula = class ~ .,
        data = protocol_subset,
        importance = "impurity",
        num.trees = 50,
        verbose = FALSE
      )
      
      # Get importance
      imp <- importance(protocol_model)
      
      # Create data frame
      imp_df <- data.frame(
        Feature = names(imp),
        Importance = as.numeric(imp),
        Protocol = protocol,
        stringsAsFactors = FALSE
      )
      
      # Sort by importance
      imp_df <- imp_df[order(-imp_df$Importance), ]
      
      # Keep top 10 features
      imp_df <- imp_df[1:min(10, nrow(imp_df)), ]
      
      # Store in list
      importance_by_protocol[[protocol]] <- imp_df
    }, error = function(e) {
      cat("Error in protocol", protocol, ":", e$message, "\n")
    })
  }
  
  # Combine all importance data frames
  all_importance <- do.call(rbind, importance_by_protocol)
  
  # Create plot
  p <- ggplot(all_importance, aes(x = reorder(Feature, Importance), y = Importance, fill = Protocol)) +
    geom_bar(stat = "identity") +
    facet_wrap(~ Protocol, scales = "free_y") +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Top Features by Protocol",
      x = "Feature",
      y = "Importance",
      fill = "Protocol"
    ) +
    theme(legend.position = "none")
  
  return(p)
}

# Function to create service distribution by protocol
create_service_by_protocol <- function(data) {
  # Create a data frame of services by protocol
  service_by_protocol <- data.frame()
  
  for (protocol in unique(data$protocol_type)) {
    # Skip if protocol is NA or empty
    if (is.na(protocol) || protocol == "") next
    
    # Get protocol data
    protocol_subset <- data[data$protocol_type == protocol, ]
    
    # Skip if empty
    if (nrow(protocol_subset) == 0) next
    
    # Skip if no service column
    if (!"service" %in% colnames(protocol_subset)) next
    
    # Count services (top 10)
    service_counts <- sort(table(protocol_subset$service), decreasing = TRUE)
    service_counts <- service_counts[1:min(10, length(service_counts))]
    
    # Calculate percentages
    service_percentages <- 100 * service_counts / sum(service_counts)
    
    # Add to data frame
    for (service in names(service_counts)) {
      # Skip empty or NA services
      if (is.na(service) || service == "") next
      
      service_by_protocol <- rbind(
        service_by_protocol,
        data.frame(
          Protocol = protocol,
          Service = service,
          Count = service_counts[service],
          Percentage = service_percentages[service],
          stringsAsFactors = FALSE
        )
      )
    }
  }
  
  # Create a grouped bar chart
  p <- ggplot(service_by_protocol, aes(x = reorder(Service, -Percentage), y = Percentage, fill = Protocol)) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    labs(
      title = "Top Services by Protocol",
      x = "Service",
      y = "Percentage",
      fill = "Protocol"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_brewer(palette = "Set1")
  
  return(p)
}

# Function to create attack success rate by protocol
create_attack_success_by_protocol <- function(data) {
  # Create a data frame of attack success by protocol
  success_by_protocol <- data.frame()
  
  for (protocol in unique(data$protocol_type)) {
    # Skip if protocol is NA or empty
    if (is.na(protocol) || protocol == "") next
    
    # Get protocol data
    protocol_subset <- data[data$protocol_type == protocol, ]
    
    # Skip if empty
    if (nrow(protocol_subset) == 0) next
    
    # Categorize attacks vs normal
    is_attack <- protocol_subset$class != "b'normal.'" 
    
    # Calculate success rate (assuming flag indicates success)
    if ("flag" %in% colnames(protocol_subset)) {
      # Count success flags for attacks
      success_flags <- c("b'S0'", "b'S1'", "b'S2'", "b'S3'", "b'SF'", "b'SH'")
      
      # Calculate success rates for attacks
      attack_success <- mean(protocol_subset$flag[is_attack] %in% success_flags, na.rm = TRUE) * 100
      
      # Add to data frame
      success_by_protocol <- rbind(
        success_by_protocol,
        data.frame(
          Protocol = protocol,
          SuccessRate = attack_success,
          stringsAsFactors = FALSE
        )
      )
    }
  }
  
  # Create a bar chart if we have data
  if (nrow(success_by_protocol) > 0) {
    p <- ggplot(success_by_protocol, aes(x = Protocol, y = SuccessRate, fill = Protocol)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      labs(
        title = "Attack Success Rate by Protocol",
        x = "Protocol",
        y = "Success Rate (%)",
        fill = "Protocol"
      ) +
      theme(legend.position = "none") +
      scale_fill_brewer(palette = "Set1")
    
    return(p)
  } else {
    return(NULL)
  }
}
