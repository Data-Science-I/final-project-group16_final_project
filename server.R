# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.

library(shiny)
library(plotly)
library(mosaic)
library(sf)
library(leaflet)
library(dplyr)
library(here)
library(usmap)

# Load the dataset
data <- read.csv(here("Dataset/acs_final_dataset.csv"))

state_to_fips <- data.frame(
  state = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida",
            "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
            "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico",
            "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", 
            "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming", "Puerto Rico"),
  STATEFP = c("01", "02", "04", "05", "06", "08", "09", "10", "11", "12", "13", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", 
              "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "44", "45", "46", "47", "48", 
              "49", "50", "51", "53", "54", "55", "56", "72")
)

# Define descriptions for each variable
variable_descriptions <- list(
  old_population = list(
    title = "Old Population (%)",
    description = "Percentage of the total population aged 65 and older.",
    source = "Source Table: B01001 (Sex by Age).",
    creation = "Sum of age-specific populations divided by the total population, multiplied by 100."
  ),
  white_population = list(
    title = "White Population (%)",
    description = "Percentage of the total population identified as White.",
    source = "Source Table: B02001 (Race).",
    creation = "White population divided by the total population, multiplied by 100."
  ),
  car_commute = list(
    title = "Car Commute Time (mins)",
    description = "Percentage of workers who commute by car.",
    source = "Source Table: B08006 (Means of Transportation to Work by Workers).",
    creation = "Car commuters divided by the total population, multiplied by 100."
  ),
  local_workers = list(
    title = "Local Workers (%)",
    description = "Percentage of workers living and working in the same county.",
    source = "Source Table: B08007 (Place of Work for Workers).",
    creation = "Local workers divided by the total population, multiplied by 100."
  ),
  bachelor_degree = list(
    title = "Bachelor's Degree (%)",
    description = "Percentage of the population aged 25 or older with a bachelor's degree or higher.",
    source = "Source Table: B15003 (Educational Attainment).",
    creation = "Bachelor's degree holders divided by the total population, multiplied by 100."
  ),
  renter_occupied = list(
    title = "Renter Occupied (%)",
    description = "Percentage of housing units that are renter-occupied.",
    source = "Source Table: B25003 (Tenure).",
    creation = "Renter-occupied units divided by total households, multiplied by 100."
  ),
  median_income = list(
    title = "Median Income ($)",
    description = "Median household income.",
    source = "Source Table: B19013 (Median Household Income).",
    creation = "Directly retrieved as the median household income estimate."
  ),
  health_insurance = list(
    title = "Health Insurance (%)",
    description = "Percentage of the population with health insurance.",
    source = "Source Table: B27001 (Health Insurance Coverage Status).",
    creation = "Population with health insurance divided by the total population, multiplied by 100."
  ),
  below_poverty = list(
    title = "Below Poverty (%)",
    description = "Percentage of the population below the poverty level.",
    source = "Source Table: B17001 (Poverty Status).",
    creation = "Population below poverty divided by the total population, multiplied by 100."
  ),
  internet_household = list(
    title = "Internet Household (%)",
    description = "Percentage of households with internet access.",
    source = "Source Table: B28002 (Presence and Types of Internet Subscriptions).",
    creation = "Households with internet access divided by total households, multiplied by 100."
  )
)


# Match state names to FIPS codes
data <- merge(data, state_to_fips, by.x = "state", by.y = "state", all.x = TRUE)

# Server logic
shinyServer(function(input, output) {
  
  # Dynamically render variable descriptions based on user selection
  output$dynamicDescription <- renderUI({
    var <- input$var
    desc <- variable_descriptions[[var]]
    
    if (is.null(desc)) {
      return(h4("Please select a variable to see the description."))
    }
    
    tagList(
      h4(desc$title),
      p(strong("Description:"), desc$description),
      p(strong("Source:"), desc$source),
      p(strong("Creation:"), desc$creation)
    )
  })
  
  # Render the interactive histogram
  output$interactivePlot <- renderPlotly({
    selected_var <- input$var
    hist_data <- data[[selected_var]]
    
    plot_ly(
      x = hist_data,
      type = "histogram",
      nbinsx = input$bins
    ) %>%
      layout(
        title = paste("Histogram of", gsub("_", " ", selected_var)),
        xaxis = list(title = gsub("_", " ", selected_var)),
        yaxis = list(title = "Frequency")
      )
  })
  
  # Render the summary statistics table
  output$summaryTable <- renderTable({
    selected_var <- input$var
    variable_data <- data[[selected_var]]
    
    # Calculate summary statistics using favstats
    stats <- favstats(variable_data)
    
    # Add the number of missing values
    stats$missing <- sum(is.na(variable_data))
    
    # Format as a table
    summary_table <- data.frame(
      Statistic = c("Min", "Q1", "Median", "Q3", "Max", "Mean", "SD", "# Missing"),
      Value = c(
        stats$min, stats$Q1, stats$median, stats$Q3, stats$max, 
        stats$mean, stats$sd, stats$missing
      )
    )
    
    return(summary_table)
  })

  # Render the spatial map for any selected variable using usmap
  output$spatialMap <- renderPlotly({
    selected_var <- input$var
    
    # Ensure the selected variable is numeric and handle missing data
    data[[selected_var]] <- as.numeric(data[[selected_var]])
    data[[selected_var]] <- ifelse(is.na(data[[selected_var]]), 0, data[[selected_var]])
    
    # Map data to state abbreviations
    plot_data <- data %>%
      group_by(state) %>%
      summarize(value = mean(!!sym(selected_var), na.rm = TRUE))
    
    # Create a usmap plot
    usmap_plot <- plot_usmap(
      regions = "states",
      data = plot_data,
      values = "value",
      color = "white"
    ) +
      scale_fill_continuous(
        low = "white", high = "darkblue", 
        name = gsub("_", " ", selected_var)
      ) +
      labs(
        title = paste("US Map of", gsub("_", " ", selected_var)),
        fill = gsub("_", " ", selected_var)
      ) +
      theme(legend.position = "right")
    
    # Use plotly for interactivity
    ggplotly(usmap_plot)
  })
  # Perform clustering and return cluster assignments
  reactive_clusters <- reactive({
    k <- input$num_clusters
    selected_vars <- input$clustering_vars
    clustering_data <- data %>%
      select(all_of(selected_vars)) %>%
      na.omit()
    
    # Scale the data
    scaled_data <- scale(clustering_data)
    
    # Perform k-means clustering
    kmeans_result <- kmeans(scaled_data, centers = k, nstart = 20)
    
    # Add cluster assignments to the data
    data_with_clusters <- data %>%
      mutate(cluster = as.factor(kmeans_result$cluster))
    
    return(data_with_clusters)
  })
  
  # Render the clustering results on the US map
  output$clusterMap <- renderPlotly({
    clustered_data <- reactive_clusters()
    
    # Create the map with usmap
    usmap_plot <- plot_usmap(
      regions = "states",
      data = clustered_data,
      values = "cluster",
      color = "white"
    ) +
      scale_fill_brewer(palette = "Set3", name = "Cluster") +
      labs(
        title = "Clustering Results by State",
        subtitle = paste("k =", input$num_clusters)
      ) +
      theme(legend.position = "right")
    
    ggplotly(usmap_plot)
  })
  
  # Render the text summary for clustering
  output$clusterSummary <- renderText({
    paste("The clustering analysis divides the states into", input$num_clusters, 
          "clusters based on the selected variables. Each cluster groups states with similar profiles.",
          "Explore the map to see the distribution of clusters.")
  })
  
  # Scree plot for selecting number of clusters
  output$screePlot <- renderPlot({
    selected_vars <- input$clustering_vars
    clustering_data <- data %>%
      select(all_of(selected_vars)) %>%
      na.omit()
    
    # Scale the data
    scaled_data <- scale(clustering_data)
    
    # Compute total within-cluster sum of squares (WSS) for 1 to 10 clusters
    wss <- sapply(1:10, function(k) {
      kmeans(scaled_data, centers = k, nstart = 20)$tot.withinss
    })
    
    # Create scree plot
    plot(1:10, wss, type = "b", pch = 19, col = "blue",
         xlab = "Number of Clusters (k)", ylab = "Total Within-Cluster Sum of Squares",
         main = "Scree Plot for Choosing Optimal k")
  })
})
