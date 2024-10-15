
#first we load the shiny package:

library(shiny)
library(ggplot2)

#Next we define the user interface by calling the function
# `pageWithSidebar`:

ui <- fluidPage(
    
    #App title ----
    titlePanel("Mile Per Gallon"),
    
    #Sidebar layout with input and output definitions
    sidebarLayout(
    
        # Sidebar panel for inputs ---
        
        sidebarPanel(
            
            # Input: Selector for variable to plot against mpg---
            selectInput(inputId = "variable", 
                        label = "Variable:", 
                        choices = c("Cylinders"="cyl", 
                                    "Transmission" = "am", 
                                    "Gears"="gear")),
            
            #Input: Checkbx for whether outliers should be included-----
            checkboxInput(inputId = "outliers", 
                          label = "Show outliers", value = TRUE)
        ), 
        
        #Main panel for displaying outputs -- 
        
        mainPanel(
            
            #Output: Formatted text for caption ---
            h3(textOutput("caption")),
            
            # Output: Plot of the requested variable agains mpg ---
            plotOutput("mpgPlot")
            
        )
    )
)

# Define server logic to plot various variables again mpg ---

#Tweak the "am" variable to have nicer factor labels -- since this 
#doesn't rely on any user inputs, we can do this once at the startup
#and then use the value throughout the lifetime of the app
mpgData <- mtcars
mpgData$am <- factor(x = mpgData$am, labels = c("Automatic", "Maunal"))

server <- function(input, output){
    
    #Compute the formula text ----
    #This is in a reactive expression since it is shared by the 
    #output$caption and output$mpgPlot functions
    formulaText <- reactive({
        paste("mpg ~", input$variable)
    })
    
    #Return the formula text for printing as a caption ----
    output$caption <- renderText({
        formulaText()
    })
    
    #Generate a plot of the requested vairable against mpg ---
    # and only exclude outliers if requested
    output$mpgPlot <- renderPlot({
        boxplot(as.formula(formulaText()), 
                data=mpgData, 
                outline=input$outliers, 
                col="#75AADB", pch=19)
      })
    
}


# Run the application 
shinyApp(ui = ui, server = server)
