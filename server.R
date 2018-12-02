library(shiny)
library(ggplot2)
library(dplyr)
library(tree)

# Define a server for the Shiny app
shinyServer(function(input, output) {
  newData <- diamonds %>% filter(carat > 1)
  
  #for the information tab content (tab 1)
  output$info <- renderUI({
    h4("This is analysis of a dataset-diamonds from the ggplot2 package, it contains the prices and other attributes of almost 54,000 diamonds.")
  })
  
  #include a link
  url <- a("Please find detail informations of this data set by clicking here", href="https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf")
  output$link <- renderUI({
    tagList("Detail:", url)
  })
  
  # plot for 2nd tab: a scatter plot
  plot1 <- reactive({
    # Render a scatter plot
    if(input$carats){ #1st dynamic UI
      if(input$cuts){ #2nd dynamic UI
        ggplot(newData, aes(x = carat, y = price)) + geom_point(aes(color = factor(cut))) +
          scale_color_discrete(name = "cut")
      } else {
        ggplot(newData, aes(carat, price))+geom_point()
      }
    } else {
      ggplot(diamonds, aes(carat, price))+geom_point()
    }
  })
  
  output$plot1 <- renderPlot({
    plot1()
  })
  
  # plot for 3rd tab: a heatmap
  plot2 <- reactive({
    if(input$carats){
      if(input$cuts){
        ggplot(newData, aes(carat, price)) +
          stat_bin2d(aes(alpha = factor(cut)))
      } else {
        ggplot(newData, aes(carat, price))+
          stat_bin2d(bin=25, color="white")
      }
    } else {
      ggplot(diamonds, aes(carat, price))+
        stat_bin2d(bin=25, color="white")
    }
  })
  
  output$plot2 <- renderPlot({
    plot2()
  })
  
  #for clicking on the plot and select a region to show the data accordingly
  #for clicking the scatter plot (2nd tab)
  output$subsets <- renderPrint({
    brushedPoints(diamonds, input$plot_brush, xvar = "carat", yvar = "price")
  })
  
  #for clicking the heatmap (3rd tab)
  output$subsets2 <- renderPrint({
    brushedPoints(diamonds, input$plot_brush, xvar = "carat", yvar = "price")
  })
  
  #for the 4th tab:show data set that been used
  Dataset <- reactive({
    if(input$carats){
      Data<-newData
    } else {
      Data<-diamonds
    }
  })
  
  output$datasets <- renderDataTable(Dataset())
  
  # for 5th tab: linear regression
  modelFit <- reactive({
    if(input$selection){
      lm(as.formula(paste("price"," ~ ",paste(input$variables,collapse="+"))), data = diamonds)
    }else{
      "Please select variables."
    }
  })
  
  output$fitting <- renderPrint({modelFit()})
  
  # plot for 6th tab: Classification Tree
  treeFit <- reactive({
    newData <- diamonds
    newData$cut <- as.factor(newData$cut)
    newData$color <- as.factor(newData$color)
    newData$clarity <- as.factor(newData$clarity)
    if(input$selection){
      fit <- tree(as.formula(paste("price"," ~ ",paste(input$variables,collapse="+"))), data = newData)
      plot(fit)
      text(fit)
    }else{
      "Please select variables"
    }
  })
  
  output$tree <- renderPlot({
    treeFit()
  })
  
  # plot for 7th tab: PCA
  PCs <- reactive({
    newData <- diamonds
    newData$cut <- as.numeric(as.factor(newData$cut))
    newData$color <- as.numeric(as.factor(newData$color))
    newData$clarity <- as.numeric(as.factor(newData$clarity))
    if(input$selection){
      prcomp(select(newData, input$variables), scale = TRUE, center=TRUE)
    }else{"Please select variables"}
  })
  
  output$PCA <- renderPrint({
    PCs()
  })
  
  #add download button for different tabs
  #download button for the scatter plot (tab 2) 
  output$downloadData1 <- downloadHandler(
    filename = function(){
      paste("Relationship between carat and price-Scatter Plot", ".png", sep="")
    }, 
    content =  function(file)
    {ggsave(file,plot1())
      
    })
  
  #download button for the heatmap (tab 3)
  output$downloadData2 <- downloadHandler(
    filename = function(){
      paste("Relationship between carat and price-Heatmap", ".png", sep="")
    }, 
    content =  function(file)
    {ggsave(file,plot2())
    })
  
  #download button for the dataset been used (tab 3)
  output$downloadData3 <- downloadHandler(
    filename = function(){
      paste("Diamonds Dataset", ".csv", sep="")
    }, 
    content =  function(file)
    {write.csv(Dataset(), file, row.names = FALSE)
    })
})