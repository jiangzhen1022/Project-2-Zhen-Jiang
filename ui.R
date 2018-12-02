library(shiny)

# Define the overall UI
shinyUI(
  fluidPage(    
    
    # Give the page a title
    titlePanel("Diamonds Data"),
    
    # # Sidebar with options for the data set
    sidebarLayout(      
      sidebarPanel(
        checkboxInput("carats", h4("only show data for carat greater than 1", style = "color:red;")),
        conditionalPanel(
          condition="input.carats == '1'",
          checkboxInput("cuts", h5("Color Code Different Cut"))
        ),
        br(),
        checkboxInput("selection", h5("Select variables to be used in supervised learning and unsupervised learning", style = "color:red;")),
        conditionalPanel(
          condition="input.selection == '1'",
          checkboxGroupInput("variables", "Varibles to be used:", c("carat", "cut", "color", "clarity", "depth"))
        )
        
      ),
      
      mainPanel(
        #create built in tabs
        tabsetPanel(type = "tabs",
                    tabPanel("Dataset Information", 
                             uiOutput("info"), 
                             uiOutput("link"), 
                             #include a math symbol that need to use mathJax
                             withMathJax(helpText("May use transformations of price such as \\(\\sqrt{y}\\) to find linear relationship between carat and price")) 
                    ),
                    tabPanel("Scatter Plot", 
                             plotOutput("plot1", brush = "plot_brush"), #option for select a region on the plot 
                             downloadButton("downloadData1","Download"), 
                             verbatimTextOutput("subsets") #when select a region, show the data accordingly
                    ),
                    tabPanel("Heatmap", 
                             plotOutput("plot2", brush = "plot_brush"), #option for select a region on the plot
                             downloadButton("downloadData2","Download"), 
                             verbatimTextOutput("subsets2") #when select a region, show the data accordingly
                    ),
                    tabPanel("Dataset", 
                             dataTableOutput("datasets"), 
                             downloadButton("downloadData3","Download")),
                    tabPanel("Regression", 
                             verbatimTextOutput("fitting")),
                    tabPanel("Classification Tree", 
                             plotOutput("tree")),
                    tabPanel("PCA", 
                             verbatimTextOutput("PCA"))
        )
      )  
    )
  )
)