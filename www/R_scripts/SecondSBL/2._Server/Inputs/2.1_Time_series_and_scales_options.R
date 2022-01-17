
###############################################################################
##                                                                           ##
##              Shiny App - Time series and scales options code              ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#2.1 - Time series and scales options

#2.1.1 - Select time series to use

#Reactive value to store the selective options
select <- reactiveValues()

#Reactive value to store the possible time series options
select$timeseries <- list("Original","First transformation",
                       "Second transformation")

#Picker Input for time series.
output$select_timeseries <- renderUI({
  pickerInput("selectimeseries",
              "Time series to use",
              choices = select$timeseries,
              selected = select$timeseries,
              multiple = T,         
              options = pickerOptions(title = "Select at least one time serie",
                                      header = "Select at least one time serie",
                                      iconBase = "fa ",
                                      tickIcon = "fa-check text-primary",
                                      style = "btn-primary"))
})

#a) Disable first and second transformation if TS is already stationary and
#trigger an alert
observeEvent(input$selectamountofdatabutton,{
  if(!is.element(input$forecastv, names(database$df))){}
  else{
    valuevariable <- database$df[[input$forecastv]]
    ADF <- adf.test(valuevariable, alternative = "stationary")
    PP <- tryCatch(pp.test(valuevariable, alternative = "stationary"),
                   error = function(e)e)
    if(ADF$p.value <= 0.05 && identical(class(PP), errorclasses)||
       ADF$p.value <= 0.05 && PP$p.value <= 0.05){
      disabled_choices <- !select$timeseries %in% list("Original")  
      updatePickerInput(session = session,
                        inputId = "selectimeseries",
                        selected = "Original",
                        choices = select$timeseries,
                        choicesOpt = list(
                          disabled = disabled_choices,
                          style = ifelse(disabled_choices,
                                         yes = "color: rgba(119, 119, 119, 0.5);",
                                         no = "")
                          )
                        )
      output$alertstationary <- renderUI({
        h5("None of the transformation can be applied because the time serie selected to work with is already stationary",
           style = "color: red")
        })
    }
  }
  
})

#2.1.2 - Select scales to use
#Reactive value to store the possible scales options
select$scales <- list("Exact values","From 0 to 1",
                      "From -1 to 1")

output$select_ts_scales <- renderUI({
  pickerInput("selectimeseriescales",
              "Scales to use",
              choices = select$scales,
              selected = select$scales,
              multiple = T,         
              options = pickerOptions(title = "Select at least one scale",
                                      header = "Select at least one scale",
                                      iconBase = "fa ",
                                      tickIcon = "fa-check text-primary",
                                      style = "btn-primary"))
})

#Time series and scales options box
output$ts_and_scales_opt_box <- renderUI({
  tagList(
    div(class = "divcontainingbox",
        div(class = "headerofthedivcontainingbox",
            h4(strong("Time series"), class = "titleofheader"),
            actionButton("timeseriesopboxtogglebtt", label = "",
                         class = "buttonofheaderminimize")
        ),
        div(
          id = "TS_AND_SCALES_BOX",
          
          #2.1.1 - Select time series to use
          uiOutput("select_timeseries"),
          
          #a) Disable first and second transformation if TS is already stationary 
          #and trigger an alert
          uiOutput("alertstationary"),
          
          #2.1.2 - Select scales to use
          uiOutput("select_ts_scales"),
          
          #Button to hide time series and scales option box
          actionBttn("tsandscaleoptsbutton", "OK", color = "primary",
                     style = "fill", block = T, size = "sm"),
          
          #Alert when pressing the button
          uiOutput("alerttsscalesoptbox"),
          
          div(style = "height:1em"),
          
          style = "margin: 1em 0 0 0"
          )
        )
    )
})

#Reactive value to store if collapse or not Time series and scales options box
toggle$tsandscopbox <- 1

#Action when user click on the minimize-maximize Time series and scales options 
#box button
observeEvent(input$timeseriesopboxtogglebtt,{
  #Ad 1 to toggle$tsandscopbox to minimize or maximize
  toggle$tsandscopbox <- toggle$tsandscopbox + 1
  
  #If the training vectors box, the LSTM neurons options box and the Training
  #and testing options box are shown it give the values to reactive values toggle
  #to hidden them
  if((toggle$trainingvectorsopbox %% 2) != 0){
    toggle$trainingvectorsopbox <- toggle$trainingvectorsopbox + 1
  }
  
  if((toggle$LSTMneuronsopbox %% 2) != 0){
    toggle$LSTMneuronsopbox <- toggle$LSTMneuronsopbox + 1
  }
  
  if((toggle$Trainingandtestingopbox %% 2) != 0){
    toggle$Trainingandtestingopbox <- toggle$Trainingandtestingopbox + 1
  }
  
  })

#Conditional to show or hide the "Time series and scales options box" depending on 
#toggle$tsandscopbox value
observe({
  
  #If toggle$tsandscopbox is even hide the time series and scales options box
  if((toggle$tsandscopbox %% 2) == 0){
    removeClass("timeseriesopboxtogglebtt","buttonofheaderminimize")
    addClass("timeseriesopboxtogglebtt","buttonofheadermaximize")
    hide("TS_AND_SCALES_BOX")
    
    #If toggle$tsandscopbox is odd show the time series and scales options box
  }else{
    removeClass("timeseriesopboxtogglebtt","buttonofheadermaximize")
    addClass("timeseriesopboxtogglebtt","buttonofheaderminimize")
    show("TS_AND_SCALES_BOX")
  }
})

#Action when user press the OK button on the "Time series and scales options" box
observeEvent(input$tsandscaleoptsbutton,{
  if(is.null(input$selectimeseries)&& is.null(input$selectimeseriescales)){
    output$alerttsscalesoptbox <- renderUI({
      h5("There are not time series or scales selected", style = "color:red")
    })
  }
  if(is.null(input$selectimeseries)&& !is.null(input$selectimeseriescales)){
    output$alerttsscalesoptbox <- renderUI({
      h5("There are not any time serie selected", style = "color:red")
    })
  }
  if(!is.null(input$selectimeseries)&& is.null(input$selectimeseriescales)){
    output$alerttsscalesoptbox <- renderUI({
      h5("There are not any scale selected", style = "color:red")
    })
  }
  if(!is.null(input$selectimeseries)&& !is.null(input$selectimeseriescales)){
    toggle$tsandscopbox <- toggle$tsandscopbox + 1
    output$alerttsscalesoptbox <- NULL
    
    #If training vectors is hidden, it give the value to toggle$trainingvectorsopbox
    #to show it
    if((toggle$trainingvectorsopbox %% 2) == 0){
      toggle$trainingvectorsopbox <- toggle$trainingvectorsopbox + 1
    }
  }
})