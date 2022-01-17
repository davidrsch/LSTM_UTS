
###############################################################################
##                                                                           ##
##                 Shiny App - Selected variables plot code                  ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#1.3- Selected variables plot

#Reactive value to store the plot
Selectedvariables <- reactiveValues()
#Reactive value to store the date-sequence variable
Selectedvariables$d_s_v <- NULL
#Reactive value to store the forecast variable
Selectedvariables$f_v <- NULL
#Reactive value to store the train set
Selectedvariables$train <- NULL
#Reactive value to store the test set
Selectedvariables$test <- NULL
#Reactive value to store the train & test sets
Selectedvariables$t_and_t <- NULL
#Reactive value to store the plot
Selectedvariables$plot <- NULL

observeEvent(c(input$selecteddatamaountstart,
               input$selecteddatamaountend,
               input$End_of_training),{
                 
                 if(!identical(database$otherdf, database$df)){
                   Selectedvariables$plot <- NULL
                 }
                else{
                  if(length(input$End_of_training) > 0){
                    
                    if(input$datevariable == ""||
                       !identical(database$df[[input$datevariable]],
                                  unique(database$df[[input$datevariable]]))){
                      
                      #Store the forecast variable
                      Selectedvariables$f_v <- as.numeric(database$df[[input$forecastv]][input$selecteddatamaountstart:input$selecteddatamaountend])
                      NAS <- whichareNA(Selectedvariables$f_v)
                      
                      #Create a sequence if there is not date-sequence variable selected or the
                      #date-sequence variable selected has repeating values and store it
                      #in Selectedvariables$d_s_v
                      Selectedvariables$d_s_v <- input$selecteddatamaountstart:input$selecteddatamaountend
                      Selectedvariables$d_s_v <- factor(Selectedvariables$d_s_v,
                                                        levels = Selectedvariables$d_s_v[1:length(Selectedvariables$d_s_v)])
                      
                      if(length(NAS) > 0){
                        Selectedvariables$f_v <- Selectedvariables$f_v[-(NAS)]
                        Selectedvariables$d_s_v <- Selectedvariables$d_s_v[-(NAS)]
                      }else{}
                      
                      #Store the variables to save the length of the Training and Test sets
                      Selectedvariables$train <- rep("1-Train set", times = length(Selectedvariables$d_s_v[input$selecteddatamaountstart:input$End_of_training]))
                      Selectedvariables$test <- rep("2-Test set", times = length(Selectedvariables$d_s_v[(as.numeric(input$End_of_training) + 1): input$selecteddatamaountend]))
                      Selectedvariables$t_and_t = c(Selectedvariables$train,Selectedvariables$test)
                      
                      }else{
                        
                        #Store the forecast variable
                        Selectedvariables$f_v <- as.numeric(database$df[[input$forecastv]][which(grepl(input$selecteddatamaountstart,database$df[[input$datevariable]])):
                                                                                  which(grepl(input$selecteddatamaountend,database$df[[input$datevariable]]))])
                        NAS <- whichareNA(Selectedvariables$f_v)
                        
                        #Store the selected variable in Selectedvariables$d_s_v
                        Selectedvariables$d_s_v <- database$df[[input$datevariable]][which(grepl(input$selecteddatamaountstart,database$df[[input$datevariable]])):
                                                                                       which(grepl(input$selecteddatamaountend,database$df[[input$datevariable]]))]
                        Selectedvariables$d_s_v <- as.factor(Selectedvariables$d_s_v)
                        Selectedvariables$d_s_v <- factor(Selectedvariables$d_s_v,
                                                          levels = Selectedvariables$d_s_v[1:length(Selectedvariables$d_s_v)])
                        
                        if(length(NAS) > 0){
                          Selectedvariables$f_v <- Selectedvariables$f_v[-(NAS)]
                          Selectedvariables$d_s_v <- Selectedvariables$d_s_v[-(NAS)]
                        }else{}
                        
                        #Store the variables to save the length of the Training and Test sets
                        Selectedvariables$train <- rep("1-Train set", times = length(Selectedvariables$d_s_v[which(grepl(input$selecteddatamaountstart,Selectedvariables$d_s_v)):
                                                                                                               which(grepl(input$End_of_training, Selectedvariables$d_s_v))]))
                        Selectedvariables$test <- rep("2-Test set", times = length(Selectedvariables$d_s_v[(which(grepl(input$End_of_training,Selectedvariables$d_s_v)) + 1):
                                                                                                             which(grepl(input$selecteddatamaountend, Selectedvariables$d_s_v))]))
                        Selectedvariables$t_and_t = c(Selectedvariables$train,Selectedvariables$test)
                        }
                    
                    if(length(Selectedvariables$t_and_t) == length(Selectedvariables$d_s_v)){
                      
                      Data_to_plot <- data.frame(Selectedvariables$d_s_v, Selectedvariables$f_v, Selectedvariables$t_and_t)
                      
                      #Store the plot
                      Selectedvariables$plot <- ggplot(Data_to_plot,
                                                       aes(x = Selectedvariables$d_s_v,y = Selectedvariables$f_v, group = 1, color = Selectedvariables$t_and_t)) +
                        geom_line() +
                        scale_colour_manual(values = c("cyan3","blue")) +
                        labs(x =  input$datevariable,
                             y = input$forecastv,
                             col = "Train & Test") +
                        scale_x_discrete(breaks  = c(as.character(Selectedvariables$d_s_v[1]),
                                                     as.character(Selectedvariables$d_s_v[round(length(Selectedvariables$d_s_v)/4)]),
                                                     as.character(Selectedvariables$d_s_v[round(length(Selectedvariables$d_s_v)/2)]),
                                                     as.character(Selectedvariables$d_s_v[length(Selectedvariables$d_s_v) - round(length(Selectedvariables$d_s_v)/4)]),
                                                     as.character(Selectedvariables$d_s_v[length(Selectedvariables$d_s_v)])),
                                         labels = c(as.character(Selectedvariables$d_s_v[1]),
                                                    as.character(Selectedvariables$d_s_v[round(length(Selectedvariables$d_s_v)/4)]),
                                                    as.character(Selectedvariables$d_s_v[round(length(Selectedvariables$d_s_v)/2)]),
                                                    as.character(Selectedvariables$d_s_v[length(Selectedvariables$d_s_v) - round(length(Selectedvariables$d_s_v)/4)]),
                                                    as.character(Selectedvariables$d_s_v[length(Selectedvariables$d_s_v)]))) +
                        theme(panel.background = element_rect(fill = "transparent"),
                              axis.title.x = element_text(vjust = -5),
                              axis.title.y = element_text(vjust = 5),
                              plot.background = element_rect(fill = "transparent",
                                                             colour = "transparent"),
                              panel.grid.minor = element_line(size = 0.25,
                                                              linetype = "solid",
                                                              colour = "grey"),
                              panel.grid.major = element_line(size = 0.25,
                                                              linetype = "solid",
                                                              colour = "grey"),
                              plot.margin = margin(20,15,20,15,"pt"),
                              legend.background = element_rect(fill = "transparent"),
                              legend.box.background = element_rect(fill = "transparent"))
                      
                      }
                    
                    }
                  
                  }
                 
                 })

#Selected variables plot box
output$plotselectedvariables <- renderUI({
    
    #Create the box that contain the plot
    tagList(
      div(class = "divcontainingbox",
          div(class = "headerofthedivcontainingbox",
              h4(strong("Uploaded database"), class = "titleofheader"),
              actionButton("plotofselectevartogglebtt",label = "",
                           class = "buttonofheaderminimize")
          ),
          
          div(
            id = "selected_variables_plot_box",
            
            renderUI({
              h5(tags$strong(input$file$name), align = "center")
              }),
            
            renderPlot({Selectedvariables$plot}),
            
            div(style = "height:1em"),
            
            style = "margin: 1em 0 0 0"
            )
          )
      )
})

#Set the selected variables plot hidden as default
observe({
  hide("plotselectedvariables")
  })

#Action when user click on the minimize-maximize selected variables plot box button  
observeEvent(input$plotofselectevartogglebtt,{
  
  toggle$plotofselectedvariables <- toggle$plotofselectedvariables + 1
  
  #If the database table is shown it give the values to reactive values
  #toggle to hide it
  if((toggle$uploadeddatabasetable %% 2) != 0){
    toggle$uploadeddatabasetable <- toggle$uploadeddatabasetable + 1
  }
  
})

observe({
  #If toggle$plotofselectedvariables is even hide the selected variables box
  if((toggle$plotofselectedvariables %% 2) == 0){
    removeClass("plotofselectevartogglebtt","buttonofheaderminimize")
    addClass("plotofselectevartogglebtt","buttonofheadermaximize")
    hide("selected_variables_plot_box")
  
    #If toggle$plotofselectedvariables is odd show the selected variables box
    }else{
      removeClass("plotofselectevartogglebtt","buttonofheadermaximize")
      addClass("plotofselectevartogglebtt","buttonofheaderminimize")
      show("selected_variables_plot_box")
      }
  })