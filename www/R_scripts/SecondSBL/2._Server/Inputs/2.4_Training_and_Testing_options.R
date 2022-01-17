
###############################################################################
##                                                                           ##
##              Shiny App - Training and testing options code                ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#2.4 - Training and testing options

#2.4.1 - Batch size
output$batchsize <- renderUI({
  tagList(
    strong("Batch size"),
    div("In order to keep the experiments simple, only",strong("stochastic gradient descent"),"is used.",
        style = "margin: 0 0 1em 0", class = "text-primary")
  )
})

#2.4.2 - Epoch
output$epoch <- renderUI({
  numericInput("selectepochamount",
               "Epoch", value = NULL, min = 1)
})

#2.4.3 - How much testing
output$testing <- renderUI({
  numericInput("selectthetestingamount",
               "Tests", value = 10, min = 1)
})

output$trainingandtestingoptbox <- renderUI({
  tagList(
    div(class = "divcontainingbox",
        div(class = "headerofthedivcontainingbox",
            h4(strong("Training & Testing"), class = "titleofheader"),
            actionButton("trainingandtestingoptboxtogglebtt", label = "",
                         class = "buttonofheaderminimize")
        ),
        div(
          id = "TRAINING_AND_TESTING_OPTIONS_BOX",
          
          #2.4.1 - Batch size
          uiOutput("batchsize"),
          
          #2.4.2 - Epoch
          uiOutput("epoch"),
          
          #2.4.3 - How much testing
          uiOutput("testing"),
          
          #Button to hide Training and testing options box
          actionBttn("Trainingandtestingoptboxbutton", "OK",
                     color = "primary", style = "fill",
                     block = T, size = "sm"),
          
          #Alert when pressing the button
          uiOutput("alertTrainingandtestingoptbox"),
          
          div(style = "height:1em"),
          
          style = "margin: 1em 0 0 0"
          )
        )
    )
})

#Reactive value to store if collapse or not Training and Testing options box
toggle$Trainingandtestingopbox <- 1

#Action when user click on the minimize-maximize Training and Testing options 
#box button
observeEvent(input$trainingandtestingoptboxtogglebtt,{
  #Ad 1 to toggle$Trainingandtestingopbox to minimize or maximize
  toggle$Trainingandtestingopbox <- toggle$Trainingandtestingopbox + 1
  
  #If the time series and scales option box, the training vectors options box and  
  #the LSTM neurons amount box are shown it give the values to reactive values
  #toggle to hidden them
  if((toggle$tsandscopbox %% 2) != 0){
    toggle$tsandscopbox <- toggle$tsandscopbox + 1
  }
  
  if((toggle$trainingvectorsopbox %% 2) != 0){
    toggle$trainingvectorsopbox <- toggle$trainingvectorsopbox + 1
  }
  
  if((toggle$LSTMneuronsopbox %% 2) != 0){
    toggle$LSTMneuronsopbox <- toggle$LSTMneuronsopbox + 1
  }
  
})

#Conditional to show or hide the "Training and testing options box" depending on 
#toggle$Trainingandtestingopbox value
observe({
  
  #If toggle$Trainingandtestingopbox is even hide the Training and Testing options box
  if((toggle$Trainingandtestingopbox %% 2) == 0){
    removeClass("trainingandtestingoptboxtogglebtt","buttonofheaderminimize")
    addClass("trainingandtestingoptboxtogglebtt","buttonofheadermaximize")
    hide("TRAINING_AND_TESTING_OPTIONS_BOX")
    
    #If toggle$Trainingandtestingopbox is odd show the Training and Testing options box
  }else{
    removeClass("trainingandtestingoptboxtogglebtt","buttonofheadermaximize")
    addClass("trainingandtestingoptboxtogglebtt","buttonofheaderminimize")
    show("TRAINING_AND_TESTING_OPTIONS_BOX")
  }
})

#Reactive value to store all the files on the directory session$token
mylist <- reactiveValues()
mylist$files <- NULL

#Action when user press the OK button of the Training and testing options box
observeEvent(input$Trainingandtestingoptboxbutton,{
  
  if(is.null(input$selectepochamount) || is.na(input$selectepochamount) ||
     is.null(input$selectthetestingamount) || is.na(input$selectthetestingamount)){
    output$alertTrainingandtestingoptbox <- renderUI({
      h5("Neither epoch nor test amounts can be undefined",style = "color:red")
    })
  }else{
    if(input$selectepochamount == 0 || input$selectthetestingamount == 0){
      output$alertTrainingandtestingoptbox <- renderUI({
        h5("Neither epoch nor test amounts can be equal to zero",style = "color:red")
        })
      }
    if(input$selectepochamount < 0 || input$selectthetestingamount < 0){
      output$alertTrainingandtestingoptbox <- renderUI({
        h5("Neither epoch nor test amounts can be a negative number",style = "color:red")
        })
      }
    if(!is.integer(input$selectepochamount) || !is.integer(input$selectthetestingamount)){
      output$alertTrainingandtestingoptbox <- renderUI({
        h5("Neither epoch nor test amounts can be a decimal number",style = "color:red")
        })
      }
    if(is.integer(input$selectepochamount) && is.integer(input$selectthetestingamount) &&
       input$selectepochamount > 0 && input$selectthetestingamount){
      output$alertTrainingandtestingoptbox <- NULL
      
      #Create progress-bar
      show_modal_progress_circle(
        text = "Starting computation",
        color = "rgb(27,137,255)",
        stroke_width = 5,
        trail_width = 5,
        easing = "linear",
        height = "400px"
      )
      Sys.sleep(1)
      #Updating progress-bar up to 1%
      update_modal_progress(
        text = paste("Creating time series", sprintf("(%02d%%)", 1)),
        value = 1 /100)
      Sys.sleep(1)
      
      #Store the individual directory path
      path_of_directorio <- paste0("www/",session$token)
      #Create the individual directory path
      directorio <- dir.create(path_of_directorio)
      dir.create(paste0(path_of_directorio,"/Models"))
      dir.create(paste0(path_of_directorio,"/www"))
      dir.create(paste0(path_of_directorio,"/www/db"))
      dir.create(paste0(path_of_directorio,"/www/logos"))
      dir.create(paste0(path_of_directorio,"/www/db/predicciones"))
      dir.create(paste0(path_of_directorio,"/www/db/predicciones_img"))
      #Store the time series transformations selected by the user
      transformofseries <- input$selectimeseries
      #Store the original time serie
      value <- Selectedvariables$f_v
      #Creating time series
      timeseries <- createseriesvalues(TS = value,
                                       transformations = transformofseries)
      #Updating progress-bar up to 5%
      update_modal_progress(
        text = paste("Creating scaled time series", sprintf("(%02d%%)", 5)),
        value = 5 /100)
      Sys.sleep(1)
      #Store the scales selected by the user
      scales <- input$selectimeseriescales
      #Creating scaled time series
      scaledTS <- createscaledseries(timeseries, scales)
      #Updating progress-bar up to 10%
      update_modal_progress(
        text = paste("Creating training vectors", sprintf("(%02d%%)", 10)),
        value = 10 /100)
      Sys.sleep(1)
      
      #Store the temporal horizon selected by the user
      th <- input$temporalhorizon
      #Store the inputs options selected by the user
      selected_inputs_values <- input$selectinputoptions
      #Create the inputs options
      lookback <- generate_inputs(input_values = selected_inputs_values,
                                  temporal_horizon = th)
      #Store the amount of data to use at training
      traiobsamount <- length(Selectedvariables$train)
      #Creating Training vectors
      trainingvectors <- creatingrollingwindows(scaledTS,
                                                lookback,
                                                th,
                                                traiobsamount)
      #Updating progress-bar up to 15%
      update_modal_progress(
        text = paste("Building models", sprintf("(%02d%%)", 15)),
        value = 15 /100)
      
      #Store the selected neurons amounts
      neurons_amounts <- input$selectneuronsoptions
      
      #Store the epoch amount
      epochs <- input$selectepochamount
      #Store the amount of models to build 
      models_to_build <- amount_of_models_to_build(transformofseries,
                                                   scales,
                                                   inputs = lookback,
                                                   neurons = neurons_amounts,
                                                   scaledTS)
      #Store the percent to update the progress bar each time a model is builded
      amount_to_uppb_per_model  <- 55/models_to_build
      #Building, compiling and saving models
      models <- build_and_compile_models(trainingvectors,
                                         transformofseries,
                                         scales,
                                         neurons_amounts,
                                         th,
                                         epochs,
                                         path_of_directorio,
                                         amount_to_uppb_per_model,
                                         models_to_build)
      #Updating progress-bar up to 75%
      update_modal_progress(
        text = paste("Testing models", sprintf("(%02d%%)", 75)),
        value = 75 /100)
      #Store the amount of test data
      test_set <- length(Selectedvariables$test)
      #Store the amount of test per model
      amountoftest <- input$selectthetestingamount
      #Store the percent to update the progress bar each time a test is done
      amount_to_uppb_per_test <- 20/(models_to_build * amountoftest)
      #Testing models
      evaluation_result <- evaluate_models(trainingvectors,
                                           models,
                                           amountoftest,
                                           series = timeseries,
                                           test_set,
                                           lookback,
                                           th,
                                           amount_to_uppb_per_test,
                                           path_of_directorio,
                                           models_to_build)
      
      #Updating progress-bar up to 100%
      for (i in 95:100) {
        if(i == 96){
          #Store the Time series in a xlsx
          write.xlsx(data.frame(TS = transformofseries),
                     file = paste0(path_of_directorio,"/www/db/Time_series.xlsx"))
          #Store the Scales in a xlsx
          write.xlsx(data.frame(Scales = scales),
                     file = paste0(path_of_directorio,"/www/db/Scales.xlsx"))
          #Store the inputs in a xlsx
          write.xlsx(data.frame(Inputs = lookback), file = paste0(path_of_directorio,
                                                                  "/www/db/Inputs.xlsx"))
          #Store the neurons amounts in a xlsx
          write.xlsx(data.frame(Neurons = neurons_amounts),
                     file = paste0(path_of_directorio,"/www/db/Neurons.xlsx"))
        }
        if(i == 97){
          #Save results
          write.xlsx(evaluation_result, file = paste0(path_of_directorio,
                                                      "/www/db/Results.xlsx"))
          #Save results in a js file
          modelresults <- toJSON(evaluation_result$Models)
          rmseresults <- toJSON(evaluation_result$RMSE, digits = NA)
          resultsjs <- paste0("var Models =", modelresults,";",
                              "var RMSE =", rmseresults, ";")
          write(resultsjs, file = paste0(path_of_directorio,"/www/db/results.js"))
          
          #Real data to plot together the obtained predictions
          #Real date-sequence variable
          Date_Sequence <- Selectedvariables$d_s_v[
            (length(Selectedvariables$d_s_v) - length(Selectedvariables$test) - th + 2):
              length(Selectedvariables$d_s_v)]
          #Real forecast value
          Value <- Selectedvariables$f_v[
            (length(Selectedvariables$f_v) - length(Selectedvariables$test) - th + 2):
              length(Selectedvariables$f_v)]
          #Real data frame
          Real <- data.frame(Date_Sequence, Value)
          write.xlsx(Real, file = paste0(path_of_directorio,"/www/db/Real.xlsx"))
        }
        if(i == 98){
          file.copy("www/logos/Gmail_logo.png",
                   paste0(path_of_directorio,
                          "/www/logos"),
                   overwrite = TRUE)
          file.copy("www/logos/GitHub_logo.png",
                    paste0(path_of_directorio,
                           "/www/logos"),
                    overwrite = TRUE)
          file.copy("www/logos/Linkedin_logo.png",
                    paste0(path_of_directorio,
                           "/www/logos"),
                    overwrite = TRUE)
          file.copy("www/rmarkdown_script/Results.Rmd",
                    path_of_directorio,
                    overwrite = TRUE)
        }
        if(i == 99){
          render(paste0(path_of_directorio,"/Results.Rmd"),
                 envir = new.env())
        }
        if(i == 100){
          file.remove(paste0(path_of_directorio,"/Results.Rmd"))
        }
        update_modal_progress(
          text = paste("Storing results", sprintf("(%02d%%)", i)),
          value = i /100)
        Sys.sleep(1)
      }
      
      
      
      #Remove the progress bar
      remove_modal_progress()
      
      #Store the models and results on the reactive value mylist$files
      mylist$files <- list.files(paste0("www/",session$token),"*.*")
      
      #Hide the first and second div
      hide("Firstdiv")
      hide("SSBL")
      #Show the results div
      show("downloaddiv")
      
      }
    }
})

#To show Training and testing options box when user accept the LSTM amount
#box parameters
#Set hidden by default
observe({
  hide("trainingandtestingoptbox")
})

#To show and toggle the LSTM neurons amounts options box
observeEvent(input$LSTMneuronsamountboxbutton,{
  if(!is.null(input$selectneuronsoptions)){
    show("trainingandtestingoptbox")
    updateTabsetPanel(session, "Proposal_tabsetPanel",
                      selected = "Training_and_testing_options_tabPanel")
  }
})