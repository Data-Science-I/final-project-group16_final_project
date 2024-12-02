library(shiny)
library(plotly)

shinyUI(fluidPage(
  titlePanel("Interactive Data Exploration"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Data Overview"),
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
      
      # Select a variable for the "Variables" tab
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
      sliderInput("bins", "Number of bins:", min = 5, max = 50, value = 20),
      
      # Additional controls for "Unsupervised Learning"
      conditionalPanel(
        condition = "input.tabs == 'Unsupervised Learning'",
        h4("Cluster Analysis Controls"),
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
          selected = c("old_population", "local_workers", "median_income", "white_population"),
          multiple = TRUE
        ),
        sliderInput("num_clusters", "Number of Clusters (k):", min = 2, max = 10, value = 3)
      )
    ),
    
    mainPanel(
      tabsetPanel(
        id = "tabs",
        
        # Variables Section
        tabPanel("Variables",
                 tabsetPanel(
                   tabPanel("Variable Descriptions", 
                            uiOutput("dynamicDescription")
                   ),
                   tabPanel("Histogram", plotlyOutput("interactivePlot")),
                   tabPanel("Summary Table", tableOutput("summaryTable")),
                   tabPanel("Map", plotlyOutput("spatialMap", height = "600px"))
                 )
        ),
        
        # Unsupervised Learning Section
        tabPanel("Unsupervised Learning",
                 h4("Cluster Analysis"),
                 plotlyOutput("clusterMap", height = "600px"),
                 plotOutput("screePlot", height = "400px"),
                 h4("Interpretation of Results"),
                 textOutput("clusterSummary")
        )
      )
    )
  )
))
