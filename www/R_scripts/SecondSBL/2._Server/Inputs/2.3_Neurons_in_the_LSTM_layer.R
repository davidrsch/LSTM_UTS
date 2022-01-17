
###############################################################################
##                                                                           ##
##                Shiny App - Neurons in the LSTM layer code                 ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#2.3 - Neurons in the LSTM layer

#2.3.1 - Select the neuron amounts to try on:
#Reactive value to store the possible LSTM neurons amounts
select$LSTM_neuons <- list("same as inputs","16","32","64","128")

output$select_neurons_amounts <- renderUI({
  pickerInput("selectneuronsoptions",
              "Select the amounts of neurons",
              choices = select$LSTM_neuons,
              selected = select$LSTM_neuons,
              multiple = T,         
              options = pickerOptions(title = "Select at least one neurons amount",
                                      header = "Select at least one neurons amount",
                                      iconBase = "fa ",
                                      tickIcon = "fa-check text-primary",
                                      style = "btn-primary",
                                      size = 3))
})

#2.3.2 - Ad and accept a neuron's amount option
#a) - Ad a neurons amount
output$add_neurons_amount <- renderUI({
  numericInput("addneuronsamount",
               "Add other neuron amount", value = NULL, min = 1)
})

#b) - Accept the added neuron amount
output$acept_addedneuron_btt <- renderUI({
  actionBttn("acceptneuronamountbutton", "Add amount",
             color = "primary", style = "fill",
             block = T, size = "sm")
})

#c) - Action and alerts on the accept neuron amount button
observeEvent(input$acceptneuronamountbutton,{
  
  if(is.null(input$addneuronsamount)||is.na(input$addneuronsamount)){
    output$alert_no_neuronto_add <- renderUI({
      h5("No amount to add", style = "color:red")
      })
  }
  else{
    if(input$addneuronsamount < 0){
      output$alert_no_neuronto_add <- renderUI({
        h5("Inappropriate amount. Negatives numbers are not allowed", style = "color:red")
        })
    }
    if(input$addneuronsamount == 0){
      output$alert_no_neuronto_add <- renderUI({
        h5("Inappropriate amount. Zero is not allowed", style = "color:red")
        })
    }
    if(!is.integer(input$addneuronsamount)){
      output$alert_no_neuronto_add <- renderUI({
        h5("Inappropriate amount. Decimals numbers are not allowed", style = "color:red")
        })
    }
    if(is.element(input$addneuronsamount, select$LSTM_neuons)){
      output$alert_no_neuronto_add <- renderUI({
        h5("Inappropriate amount. It is already among the options", style = "color:red")
        })
    }
    if(is.integer(input$addneuronsamount) && input$addneuronsamount > 0 &&
       !is.element(input$addneuronsamount, select$LSTM_neuons)){
      select$LSTM_neuons <- c(select$LSTM_neuons, input$addneuronsamount)
      updatePickerInput(session,
                        "selectneuronsoptions",
                        choices = select$LSTM_neuons,
                        selected = c(input$selectneuronsoptions,
                                     input$addneuronsamount))
      output$alert_no_neuronto_add <- NULL
    }
    
  }
  
  
})

#LSTM neurons options box
output$lstm_neurons_box <- renderUI({
  tagList(
    div(class = "divcontainingbox",
        div(class = "headerofthedivcontainingbox",
            h4(strong("LSTM"), class = "titleofheader"),
            actionButton("LSTMneuronsopboxtogglebtt", label = "",
                         class = "buttonofheaderminimize")
        ),
        div(
          id = "LSTM_NEURONS_BOX",
          
          #2.3.1 - Select neurons amounts
          uiOutput("select_neurons_amounts"),
          
          #2.3.2 - Ad and accept a neuron's amount option
          #a) - Ad a neurons amount
          uiOutput("add_neurons_amount"),
          
          #b) - Accept the added neuron amount
          uiOutput("acept_addedneuron_btt"),
          
          #c) - Action and alerts on the accept neuron amount button
          uiOutput("alert_no_neuronto_add"),
          
          div(style = "width:12; height: 1em; clear: both"),
          
          #Button to hide LSTM neurons option box
          actionBttn("LSTMneuronsamountboxbutton", "OK",
                     color = "primary", style = "fill",
                     block = T, size = "sm"),
          
          #Alert when pressing the button
          uiOutput("alertLSTMneuronsamountoptions"),
          
          div(style = "height:1em"),
          
          style = "margin: 1em 0 0 0"
          
          )
        )
    )
  })

#Reactive value to store if collapse or not LSTM neurons options box
toggle$LSTMneuronsopbox <- 1

#Action when user click on the minimize-maximize LSTM neurons options 
#box button
observeEvent(input$LSTMneuronsopboxtogglebtt,{
  #Ad 1 to toggle$LSTMneuronsopbox to minimize or maximize
  toggle$LSTMneuronsopbox <- toggle$LSTMneuronsopbox + 1
  
  #If the time series and scales option box, the training vectors options box and  
  #the Training and testing options box are shown it give the values to reactive
  #values toggle to hidden them
  if((toggle$tsandscopbox %% 2) != 0){
    toggle$tsandscopbox <- toggle$tsandscopbox + 1
  }
  
  if((toggle$trainingvectorsopbox %% 2) != 0){
    toggle$trainingvectorsopbox <- toggle$trainingvectorsopbox + 1
  }
  
  if((toggle$Trainingandtestingopbox %% 2) != 0){
    toggle$Trainingandtestingopbox <- toggle$Trainingandtestingopbox + 1
  }
  
})

#Conditional to show or hide the "LSTM neurons options box" depending on 
#toggle$LSTMneuronsopbox value
observe({
  
  #If toggle$LSTMneuronsopbox is even hide the LSTM neurons options box
  if((toggle$LSTMneuronsopbox %% 2) == 0){
    removeClass("LSTMneuronsopboxtogglebtt","buttonofheaderminimize")
    addClass("LSTMneuronsopboxtogglebtt","buttonofheadermaximize")
    hide("LSTM_NEURONS_BOX")
    
    #If toggle$LSTMneuronsopbox is odd show the LSTM neurons options box
  }else{
    removeClass("LSTMneuronsopboxtogglebtt","buttonofheadermaximize")
    addClass("LSTMneuronsopboxtogglebtt","buttonofheaderminimize")
    show("LSTM_NEURONS_BOX")
  }
})

#Action when user press the OK button of the LSTM neurons amounts options box
observeEvent(input$LSTMneuronsamountboxbutton,{
  if(is.null(input$selectneuronsoptions)){
    output$alertLSTMneuronsamountoptions <- renderUI({
      h5("There is not any LSTM aneurons amount selected", style = "color:red")
    })
  }
  if(!is.null(input$selectneuronsoptions)){
    output$alertLSTMneuronsamountoptions <- NULL
    toggle$LSTMneuronsopbox <- toggle$LSTMneuronsopbox + 1
    
    #If Training and testing amount is hidden, it give the value to
    #toggle$Trainingandtestingopbox to show it
    if((toggle$Trainingandtestingopbox %% 2) == 0){
      toggle$Trainingandtestingopbox <- toggle$Trainingandtestingopbox + 1
    }
  }
})


#To show LSTM neurons options box when user accept the training vectors
#box parameters
#Set hidden by default
observe({
  hide("lstm_neurons_box")
})

#To show and toggle the training vectors options box
observeEvent(input$trainingvectorsoptsbutton,{
  
  if(is.null(input$temporalhorizon)||is.na(input$temporalhorizon)){
    a <- TRUE
  }else{
    a<- FALSE
  }
  
  if(isFALSE(a) &&
     !is.null(input$selectinputoptions)){
    
    show("lstm_neurons_box")
    updateTabsetPanel(session, "Proposal_tabsetPanel",
                      selected = "Neurons_LSTMlayer_tabPanel")
  }
})