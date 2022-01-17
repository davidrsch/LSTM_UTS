
###############################################################################
##                                                                           ##
##               Shiny App - Select amount of data to use code               ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#1.4 - Select amount of data to use

#1.4.1 - Select amount of data to use
output$selectamounttouse <- renderUI({
  if(input$datevariable == ""||
     !identical(database$df[[input$datevariable]], unique(database$df[[input$datevariable]]))){
    tagList(
      
      #Div containing title and dropdown
      div(style = "position: relative",
          
          #Title
          strong("Select the data to use", style = "float: left; margin: 0 1em 0 0"),
          
          #Dropdown:
          dropdown(
            #Picker input to select the start value of the date-sequence variable
            pickerInput(inputId = "selecteddatamaountstart",
                        label = "Start",
                        choices = 1:length(database$df[[input$forecastv]]),
                        selected = 1,
                        options = pickerOptions(
                          liveSearch = TRUE,
                          size = 3,
                          style = "btn-primary")),
            
            #Picker input to select the end value of the date-sequence variable
            pickerInput(inputId = "selecteddatamaountend",
                        label = "End",
                        choices = 1:length(database$df[[input$forecastv]]),
                        selected = length(database$df[[input$forecastv]]),
                        options = pickerOptions(
                          liveSearch = TRUE,
                          size = 3,
                          style = "btn-primary")),
            #Style the dropdown
            status = "primary",
            size = "xs",
            width = "100%")
          )
      )
  }else{
    tagList(
      
      #Div containing title and dropdown
      div(style = "position: relative",
          
          #Title
          strong("Select the data to use", style = "float: left; margin: 0 1em 0 0"),
          
          #Dropdown:
          dropdown(
            #Picker input to select the start value of the date-sequence variable
            pickerInput(inputId = "selecteddatamaountstart",
                        label = "Start",
                        choices = as.character(database$df[[input$datevariable]]),
                        selected = as.character(database$df[[input$datevariable]][1]),
                        options = pickerOptions(
                          liveSearch = TRUE,
                          size = 3,
                          style = "btn-primary")),
            #Picker input to select the end value of the date-sequence variable
            pickerInput(inputId = "selecteddatamaountend",
                        label = "End",
                        choices = as.character(database$df[[input$datevariable]]),
                        selected = as.character(database$df[[input$datevariable]][length(database$df[[input$datevariable]])]),
                        options = pickerOptions(
                          liveSearch = TRUE,
                          size = 3,
                          style = "btn-primary")),
            #Style the dropdown
            status = "primary",
            size = "xs",
            width = "100%")
          )
      )
    }
  
})

#Reactive values to the pickerInput of training set end
train <- reactiveValues()
train$choices <- NULL
train$selected <- NULL

observeEvent(c(input$selecteddatamaountstart,input$selecteddatamaountend),{
  
  if(input$datevariable == ""||
     !identical(database$df[[input$datevariable]], unique(database$df[[input$datevariable]]))){
    
    train$choices <- input$selecteddatamaountstart : input$selecteddatamaountend
    train$selected <- train$choices[round(0.9 * length(train$choices))]
    
    }else{
      
      train$choices <- database$df[[input$datevariable]][which(grepl(input$selecteddatamaountstart,database$df[[input$datevariable]])):
                                                         which(grepl(input$selecteddatamaountend,database$df[[input$datevariable]]))]
      train$selected <- database$df[[input$datevariable]][round(0.9 * length(train$choices))]
  
      }
})

#1.4.2 - Select the end of training
output$endoftraining <- renderUI({
  
  pickerInput("End_of_training",
              "Select the Training Set end",
              choices = as.character(train$choices),
              selected = as.character(train$selected),
              options = pickerOptions(
                liveSearch = TRUE,
                size = 3,
                style = "btn-primary"))
    
    
})


#Select amount of data to use box
output$selectamounttousebox <- renderUI({
  tagList(
    div(class = "divcontainingbox",
        div(class = "headerofthedivcontainingbox",
            h4(strong("Amount of data"), class = "titleofheader"),
            actionButton("amountofdatatouseboxtogglebtt",label = "",
                         class = "buttonofheaderminimize")
        ),
        div(
          id = "select_amount_of_data_to_use_box",
          
          #Alert if there is not date-sequence data selected
          uiOutput("sequencealert"),
          
          #1.4.1 - Select amount of data to use slider
          uiOutput("selectamounttouse"),
          
          div(style = "height:1em"),
          
          #1.4.2 - Select the end of training
          uiOutput("endoftraining"),
          
          #1.4.3 - Button to hide "Select amount of data to use box" when user
          #select the desire amount
          #a) - Button
          actionBttn("selectamountofdatabutton", "OK", color = "primary",
                     style = "fill", block = T, size = "sm"),
          
          div(style = "height:1em"),
          
          style = "margin: 1em 0 0 0"
      
      )
    )
  )
})

#Action when user click on the minimize-maximize amount of data to use box button
observeEvent(input$amountofdatatouseboxtogglebtt,{
  
  toggle$amountofdatabox <- toggle$amountofdatabox + 1
  
  #If the imported file options box and the select variables box are shown it give
  #the values to reactive values toggle to hidden them
  if((toggle$impfilebox %% 2) != 0){
    toggle$impfilebox <- toggle$impfilebox + 1
  }
  
  if((toggle$selecvariablebox %% 2) != 0){
    toggle$selecvariablebox <- toggle$selecvariablebox + 1
  }
  
})

#Conditional to show or hide the "Select amount of data box" depending on 
#toggle$amountofdatabox value
observe({
  
  #If toggle$amountofdatabox is even hide the select the amount of data box
  if((toggle$amountofdatabox %% 2) == 0){
    removeClass("amountofdatatouseboxtogglebtt","buttonofheaderminimize")
    addClass("amountofdatatouseboxtogglebtt","buttonofheadermaximize")
    hide("select_amount_of_data_to_use_box")
    
    #If toggle$amountofdatabox is odd show the select the amount of data box
    }else{
    removeClass("amountofdatatouseboxtogglebtt","buttonofheadermaximize")
    addClass("amountofdatatouseboxtogglebtt","buttonofheaderminimize")
    show("select_amount_of_data_to_use_box")
    }
})

#To show the Select amount of data to use box 
#Establish hide as default
observe({
  hide("selectamounttousebox")
})

#Show when user press the OK button of the "Select variable box"
observeEvent(input$selectvariablebutton,{
  
  #If there is not forecast variable selected do nothing
  if(!is.element(input$forecastv, names(database$df))){ }
  
  #If there is forecast variable selected
  else{
    
    #If there is no date-sequence variable selected alert the user about it
    if(input$datevariable == ""){
      output$sequencealert <- renderUI({
        h5("No date-sequence variable selected. A sequence has been created as independent variable",
           style = "color: red")
      })
    }
    
    #If there are duplicated values in the selected date-sequence variable
    if(!identical(database$df[[input$datevariable]], unique(database$df[[input$datevariable]]))){
      output$sequencealert <- renderUI({
        h5("The date-sequence variable selected has duplicated values. A sequence has been created as independent variable",
           style = "color: red")
      })
    }
    
    #No alert if there is date-sequence variable selected
    if(input$datevariable != "" &&
       identical(database$df[[input$datevariable]], unique(database$df[[input$datevariable]]))){
      
      output$sequencealert <- NULL
    
      }
    
    #Show both the select amount box and the plot of the selected variables
    show("selectamounttousebox")
    show("plotselectedvariables")
    
    #To hide the uploaded database table
    if((toggle$uploadeddatabasetable %% 2) != 0){
      toggle$uploadeddatabasetable <- toggle$uploadeddatabasetable + 1
    }
    
    #To show the selected variables plot
    if((toggle$plotofselectedvariables %% 2) == 0){
      toggle$plotofselectedvariables <- toggle$plotofselectedvariables + 1
    }
    
  }
  
})