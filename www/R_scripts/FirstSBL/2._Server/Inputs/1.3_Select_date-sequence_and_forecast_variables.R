
###############################################################################
##                                                                           ##
##      Shiny App - Select date-sequence and forecast variables code         ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#1.3 - Select the date-sequence variable and the variable to forecast

##1.3.1 - Select the date-sequence variable
output$datev <- renderUI({
  pickerInput("datevariable",
              "Select the date-sequence variable",
              choices = names(database$df),
              selected = NULL,   
              options = pickerOptions(
                title = "Select one option",
                style = "btn-primary")
              )
  
})


#1.3.2 - Select variable to forecast
output$forcast_v <- renderUI({
  pickerInput("forecastv",
              "Select the variable to forecast",
              choices = names(database$df)[names(database$df) != input$datevariable],
              selected = NULL,
              options = pickerOptions(
                title = "Select one option",
                style = "btn-primary")
              )
})

#To generate the "Select variables box"
#"Select variables box"
output$selectvariables <- renderUI({
  tagList(
    div(class = "divcontainingbox",
      div(class = "headerofthedivcontainingbox",
          h4(strong("Select the variables"), class = "titleofheader"),
          actionButton("selectvariablesboxtogglebtt",label = "",
                       class = "buttonofheaderminimize")
      ),
      div(
      id = "select_variables_box",
      
      #1.3.1 - Date select output-input
      uiOutput("datev"),
      
      #1.3.2 - Select variable to forecast
      uiOutput("forcast_v"),
      
      #1.3.3 - Button to hide "Select variable box" when user
      #select the variables
      #a) - Button
      actionBttn("selectvariablebutton", "OK", color = "primary",
                 style = "fill", block = T, size = "sm"),
      
      #b) - Output validating button
      uiOutput("vali_SVB"),
      
      div(style = "height:1em"),
      
      style = "margin: 1em 0 0 0"
      )
    )
  )
})

#Reactive value that store the dataframe foe been check in the plot output that
#if the dataframe change does not plot until variables are selected
database <- reactiveValues()
database$otherdf <- NULL

#Action when user clicks on the OK button of the "Select variable box"
observeEvent(input$selectvariablebutton,{
  
  if(!is.element(input$forecastv, names(database$df))){
    
    output$vali_SVB <- renderUI({
      h5("No forecast variable selected", style = "color: red")
    })
    
  }else{
    
    toggle$selecvariablebox <- toggle$selecvariablebox + 1
    output$vali_SVB <- NULL
    database$otherdf <- database$df
    
    #If amount of data box is hidden show it
    if((toggle$amountofdatabox %% 2) == 0){
      toggle$amountofdatabox <- toggle$amountofdatabox+ 1
    }
    
  }
})

#Action when user click on the minimize-maximize select variables box button
observeEvent(input$selectvariablesboxtogglebtt,{
  #Ad 1 to toggle$selecvariablebox to minimize or maximize
  toggle$selecvariablebox <- toggle$selecvariablebox + 1
  database$otherdf <- database$df
  #If the imported file options box and tht amount of data box and the plot of the 
  #variable are shown it give the values to reactive values toggle to hidden them
  if((toggle$impfilebox %% 2) != 0){
    toggle$impfilebox <- toggle$impfilebox + 1
  }
  
  if((toggle$amountofdatabox %% 2) != 0){
    toggle$amountofdatabox <- toggle$amountofdatabox + 1
  }
  
})

#Conditional to show or hide the "Select variables box" depending on 
#toggle$selecvariablebox value
observe({
  
  #If toggle$selecvariablebox is even hide the select variables box
  if((toggle$selecvariablebox %% 2) == 0){
    removeClass("selectvariablesboxtogglebtt","buttonofheaderminimize")
    addClass("selectvariablesboxtogglebtt","buttonofheadermaximize")
    hide("select_variables_box")
  
    #If toggle$selecvariablebox is odd show the select variables box
    }else{
      removeClass("selectvariablesboxtogglebtt","buttonofheadermaximize")
      addClass("selectvariablesboxtogglebtt","buttonofheaderminimize")
      show("select_variables_box")
    }
  
})

#To show the Select variables box 
#Establish hide as default
observe({
  hide("selectvariables")
})

#Show the box when user accept the import file options
observeEvent(input$fileoptionbutton,{
  show("selectvariables")
})