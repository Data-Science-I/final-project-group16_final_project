library(shiny)
library(plotly)

shinyUI(fluidPage(
  titlePanel("Interactive Data Exploration"), # Title of the app
  
  sidebarLayout(
    sidebarPanel(
      h4("Data Overview"), # Section header for the sidebar
      p("This dataset contains information about 52 states in the USA, including various demographic and economic indicators such as:"),
      tags$ul(
        tags$li("State names"),
        tags$li("Old population percentage"),
        tags$li("White population percentage"),
        tags$li("Commuting behavior, local workers, and renter occupancy rates"),
        tags$li("Median income, health insurance coverage, and poverty rates"),
        tags$li("Internet access in households")
      ),
      p("Variables were created or measured from publicly available data sources, including proportions (e.g., old population, white population) and numerical metrics (e.g., median income)."),
      
      # Dropdown menu to select a variable for display
      selectInput(
        "var",
        "Choose a variable to display:",
        choices = c(
          "Old Population (%)" = "old_population",
          "White Population (%)" = "white_population",
          "Car Commute Time (mins)" = "car_commute",
          "Local Workers (%)" = "local_workers",
          "Bachelor's Degree (%)" = "bachelor_degree",
          "Renter Occupied (%)" = "renter_occupied",
          "Median Income ($)" = "median_income",
          "Health Insurance (%)" = "health_insurance",
          "Below Poverty (%)" = "below_poverty",
          "Internet Household (%)" = "internet_household"
        )
      ),
      sliderInput("bins", "Number of bins:", min = 5, max = 50, value = 20), # Slider for selecting histogram bin size
      
      # Controls for the Unsupervised Learning tab, conditionally displayed
      conditionalPanel(
        condition = "input.tabs == 'Unsupervised Learning'", # Shows only when the Unsupervised Learning tab is selected
        h4("Cluster Analysis Controls"), # Header for cluster controls
        selectInput(
          "clustering_vars",
          "Select Variables for Clustering:",
          choices = c(
            "Old Population (%)" = "old_population",
            "White Population (%)" = "white_population",
            "Car Commute Time (mins)" = "car_commute",
            "Local Workers (%)" = "local_workers",
            "Bachelor's Degree (%)" = "bachelor_degree",
            "Renter Occupied (%)" = "renter_occupied",
            "Median Income ($)" = "median_income",
            "Health Insurance (%)" = "health_insurance",
            "Below Poverty (%)" = "below_poverty",
            "Internet Household (%)" = "internet_household"
          ),
          selected = c("old_population", "local_workers", "median_income", "white_population"), # Default selected variables
          multiple = TRUE # Allows selecting multiple variables for clustering
        ),
        sliderInput("num_clusters", "Number of Clusters (k):", min = 2, max = 10, value = 3) # Slider for selecting the number of clusters
      )
    ),
    
    mainPanel(
      tabsetPanel(
        id = "tabs", # ID for the main tabs to enable conditional display of elements
        
        # Variables Section
        tabPanel("Variables",
                 tabsetPanel(
                   tabPanel("Variable Descriptions", 
                            uiOutput("dynamicDescription") # Placeholder for dynamic descriptions of variables
                   ),
                   tabPanel("Histogram", plotlyOutput("interactivePlot")), # Plotly output for the histogram
                   tabPanel("Summary Table", tableOutput("summaryTable")), # Table output for variable summaries
                   tabPanel("Map", plotlyOutput("spatialMap", height = "600px")) # Plotly map output for geographic data
                 )
        ),
        
        # Unsupervised Learning Section
        tabPanel("Unsupervised Learning",
                 h4("Cluster Analysis"), # Header for the clustering section
                 plotlyOutput("clusterMap", height = "600px"), # Plotly output for the clustering map
                 plotOutput("screePlot", height = "400px"), # Plot output for the scree plot
                 h4("Interpretation of Results"), # Header for the cluster interpretation
                 textOutput("clusterSummary") # Text output for cluster analysis summaries
        )
      )
    )
  )
))
