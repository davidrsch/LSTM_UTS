
###############################################################################
##                                                                           ##
##                Shiny App - Training vectors options code                  ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#2.2 - Training vectors options

#2.2.1 - Temporal horizon
output$specify_th <- renderUI({
  numericInput("temporalhorizon", "Specify the temporal horizon",
               value = NULL, min = 1)
})

#2.2.2 - Look back options
#2.2.2.1 - Select the input options to try on:
#Reactive value to store the possible inputs amounts
select$inputs <- list("Same as TH",
                      "Double of TH",
                      "Triple of TH")

output$select_in_options <- renderUI({
  pickerInput("selectinputoptions",
              "Select the amounts of inputs",
              choices = select$inputs,
              selected = select$inputs,
              multiple = T,         
              options = pickerOptions(title = "Select at least one input amount",
                                      header = "Select at least one input amount",
                                      iconBase = "fa ",
                                      tickIcon = "fa-check text-primary",
                                      style = "btn-primary",
                                      size = 3))
})

#2.2.2.2 - Ad and accept an input option
#a) - Ad an input option
output$add_in_option <- renderUI({
  numericInput("addINoption",
               "Add other input amount", value = NULL, min = 1)
})

#b) - Accept the added input option
output$acept_addedin_btt <- renderUI({
  actionBttn("acceptinputoptionbutton", "Add input",
             color = "primary", style = "fill",
             block = T, size = "sm")
})

#c) - Action and alerts on the accept input option button
observeEvent(input$acceptinputoptionbutton,{
  same <- input$temporalhorizon
  Double <- 2*input$temporalhorizon
  Triple <- 3*input$temporalhorizon
  selecINoptvalue <- c(same,Double,Triple)
  
  if(is.null(input$addINoption)||is.na(input$addINoption)){
    output$alert_no_add <- renderUI({
      h5("No input amount to add", style = "color:red") 
      })
  }
  else{
    if(input$addINoption < 0){
      output$alert_no_add <- renderUI({
        h5("Inappropriate amount. Negatives numbers are not allowed", style = "color:red")
        })
    }
    if(input$addINoption == 0){
      output$alert_no_add <- renderUI({
        h5("Inappropriate amount. Zero is not allowed", style = "color:red")
        })
    }
    if(!is.integer(input$addINoption)){
      output$alert_no_add <- renderUI({
        h5("Inappropriate amount. Decimals numbers are not allowed", style = "color:red")
        })
    }
    if(is.element(input$addINoption, select$inputs)||
       is.element(input$addINoption, selecINoptvalue)){
      output$alert_no_add <- renderUI({
        h5("Inappropriate amount. It is already among the options", style = "color:red")
        })
    }
    if(is.integer(input$addINoption) && input$addINoption > 0 &&
       !is.element(input$addINoption, select$inputs)&&
       !is.element(input$addINoption,selecINoptvalue)){
      select$inputs <- c(select$inputs,input$addINoption)
      updatePickerInput(session,
                        "selectinputoptions",
                        choices = select$inputs,
                        selected = c(input$selectinputoptions,
                                     input$addINoption))
      output$alert_no_add <- NULL
    }
    
  }
})

#Training vectors options box
output$tv_opt_box <- renderUI({
  tagList(
    div(class = "divcontainingbox",
        div(class = "headerofthedivcontainingbox",
            h4(strong("Training vectors"), class = "titleofheader"),
            actionButton("trainingvectorsopboxtogglebtt", label = "",
                         class = "buttonofheaderminimize")
        ),
        div(
          id = "TV_OPT_BOX",
          
          #2.2.1 - Temporal horizon
          uiOutput("specify_th"),
          
          #2.2.2 - Look back options
          #2.2.2.1 - Select the input options to try on:
          uiOutput("select_in_options"),
          
          #2.2.2.2 - Ad and accept an input option
          #a) - Ad an input option
          uiOutput("add_in_option"),
          
          #b) - Accept the added input option
          uiOutput("acept_addedin_btt"),
          
          #c) - Action and alerts on the accept input option button
          uiOutput("alert_no_add"),
          
          div(style = "width:12; height: 1em; clear: both"),
          
          #Button to hide training vectors option box
          actionBttn("trainingvectorsoptsbutton", "OK",
                     color = "primary", style = "fill",
                     block = T, size = "sm"),
          
          #Alert when pressing the button
          uiOutput("alerttrainingvectorsbutton"),
          
          div(style = "height:1em"),
          
          style = "margin: 1em 0 0 0"
          
          )
        )
    )
  })

#Reactive value to store if collapse or not Training vectors options box
toggle$trainingvectorsopbox <- 1

#Action when user click on the minimize-maximize Training vectors options 
#box button
observeEvent(input$trainingvectorsopboxtogglebtt,{
  #Ad 1 to toggle$trainingvectorsopbox to minimize or maximize
  toggle$trainingvectorsopbox <- toggle$trainingvectorsopbox + 1
  
  #If the time series and scales option box, the LSTM neurons options box and  
  #the Training and testing options box are shown it give the values to reactive
  #values toggle to hidden them
  if((toggle$tsandscopbox %% 2) != 0){
    toggle$tsandscopbox <- toggle$tsandscopbox + 1
  }
  
  if((toggle$LSTMneuronsopbox %% 2) != 0){
    toggle$LSTMneuronsopbox <- toggle$LSTMneuronsopbox + 1
  }
  
  if((toggle$Trainingandtestingopbox %% 2) != 0){
    toggle$Trainingandtestingopbox <- toggle$Trainingandtestingopbox + 1
  }
  
})

#Conditional to show or hide the "Training vectors options box" depending on 
#toggle$trainingvectorsopbox value
observe({
  
  #If toggle$trainingvectorsopbox is even hide the training vectors options box
  if((toggle$trainingvectorsopbox %% 2) == 0){
    removeClass("trainingvectorsopboxtogglebtt","buttonofheaderminimize")
    addClass("trainingvectorsopboxtogglebtt","buttonofheadermaximize")
    hide("TV_OPT_BOX")
    
    #If toggle$trainingvectorsopbox is odd show the training vectors options box
  }else{
    removeClass("trainingvectorsopboxtogglebtt","buttonofheadermaximize")
    addClass("trainingvectorsopboxtogglebtt","buttonofheaderminimize")
    show("TV_OPT_BOX")
  }
})

#Action when user press the OK button of the Training vector options box
observeEvent(input$trainingvectorsoptsbutton,{
  
  if(is.null(input$temporalhorizon)||is.na(input$temporalhorizon)){
    a <- TRUE
  }else{
    a<- FALSE
  }
  
  if( isTRUE(a) && is.null(input$selectinputoptions)){
    output$alerttrainingvectorsbutton <- renderUI({
      h5("There are not temporal horizon or inputs amounts  selected", style = "color:red")
    })
  }
  if(isTRUE(a)&&
     !is.null(input$selectinputoptions)){
    output$alerttrainingvectorsbutton <- renderUI({
      h5("There is not temporal horizon", style = "color:red")
    })
  }
  if(isFALSE(a) &&
     is.null(input$selectinputoptions)){
    output$alerttrainingvectorsbutton <- renderUI({
      h5("There are not any input selected", style = "color:red")
    })
  }
  if(isFALSE(a) &&
     !is.null(input$selectinputoptions)){
    output$alerttrainingvectorsbutton <- NULL
    toggle$trainingvectorsopbox <- toggle$trainingvectorsopbox + 1
    
    #If LSTM neurons amount is hidden, it give the value to toggle$LSTMneuronsopbox
    #to show it
    if((toggle$LSTMneuronsopbox %% 2) == 0){
      toggle$LSTMneuronsopbox <- toggle$LSTMneuronsopbox + 1
    }
  }
  
})

#To show training vector box when user accept the time series and
#scales parameter
#Set hidden by default
observe({
  hide("tv_opt_box")
})

#To show and toggle the time series and scales options box
observeEvent(input$tsandscaleoptsbutton,{
  if(!is.null(input$selectimeseries)&& !is.null(input$selectimeseriescales)){
    
    show("tv_opt_box")
    updateTabsetPanel(session, "Proposal_tabsetPanel",
                      selected = "Training_vectors_tabPanel")
  }
})