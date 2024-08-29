
###############################################################################
##                                                                           ##
##                       Shiny App - Server code                             ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

server <- function(input,output, session){
  
  #To create a pop up alert at app start:
  # observe({
  #   shinyalert(
  #     html = T,
  #     text = tagList(
  #       tags$p(
  #         strong(
  #           "Simple implementation of LSTM networks for univariate time series forecasting"),
  #         style = "font-size: 1.9em; color:black"
  #         ),
  #       tags$br(),
  #       tags$p("Power by",
  #          style = "font-size: 1.5em; color:black; margin: .5em 0 .3em 0"),
  #       tags$img(src = "logos/R_logo.png", style = "width: 4em; height: 4em;
  #                margin-right:1em"),
  #       tags$img(src = "logos/Keras_logo.png", style = "width: 4em; height: 4em;
  #                margin-left:1em"),
  #       tags$br(),
  #       tags$br(),
  #       tags$br(),
  #       tags$p("Created by",
  #          style = "font-size: 1.5em; color:black; margin: .5em 0 .3em 0"),
  #       tags$p("David Díaz Rodríguez",
  #          style = "font-size: 1.7em; color:black; margin:0"),
  #       tags$a(href = "https://orcid.org/0000-0002-0927-9795", "0000 0002 0927 9795",
  #              style = "font-size: 1.5em; margin: .5em 0 0 0"),
  #       tags$br(),
  #       tags$a(href = "mailto:daviddrsch@gmail.com",
  #              tags$img(src = "logos/Gmail_logo.png",
  #                       style = "width: 2em; height: 2em"),
  #              style = "margin-right: .5em"),
  #       tags$a(href = "https://github.com/davidrsch",
  #              tags$img(src = "logos/GitHub_logo.png",
  #                       style = "width: 2em; height: 2em")),
  #       tags$a(href = "https://www.linkedin.com/in/david-díaz-6257951b8",
  #              tags$img(src = "logos/Linkedin_logo.png",
  #                       style = "width: 2.1em; height: 2em; margin-left:.4em")),
  #       tags$br(),
  #       tags$br()
  #     ),
  #     confirmButtonText = "Start",
  #     confirmButtonCol = "#2158c4",
  #     size = "l")
  # })
  
  #To set hidden as default to the results div
  observe({
    hide("downloaddiv")
  })
  
  #1##################IMPORTING_DATABASE_AND_SELECTING_VARIABLES###############
  #1.-INPUTS
  #1.2 - Imported file options
  source(file = "www/R_scripts/FirstSBL/2._Server/Inputs/1.2_Imported_files_opt_box.R", local = T)
  
  #1.3 - Select the date-sequence variable and the variable to forecast
  source(file = "www/R_scripts/FirstSBL/2._Server/Inputs/1.3_Select_date-sequence_and_forecast_variables.R",local = T)
  
  #1.4 - Select amount of data to use
  source(file = "www/R_scripts/FirstSBL/2._Server/Inputs/1.4_Select_amount_of_data_to_use.R", local = T)
  
  #1.-OUTPUTS
  #1.1- To upload file
  #Starting application
  output$fileupload <- renderUI({
    if(is.null(input$file))
      tags$h4(tags$strong("Upload file"), align = "center", style = "color:white")
    else if(!is.element(file_ext(input$file$datapath), readall))
      tags$h4(
        tags$strong("The upload file is not txt, csv, tsv, fwf, xlsx or xls"),
        align = "center",
        style = "color:white")

  })

  #1.2 - Imported file options
  source(file = "www/R_scripts/FirstSBL/2._Server/Outputs/1.2_Imported_files_options.R", local = T)
  
  #1.3- Selected variables plot
  source(file = "www/R_scripts/FirstSBL/2._Server/Outputs/1.3_Selected_variables_plot.R", local = T)
  
  ###########################Toggle_or_not_the_SBL#############################
  #Set FSBL box header and SSBL hidden by default
  observe({
    hide("containthebuttonofthFSBL")
    hide("SSBL")
  })
  
  #Reactive value that store if toggle or not the FSBL
  toggle$FSBL <- 1
  
  #Action when user clicks on the OK button of the "Select amount of data to use box"
  observeEvent(input$selectamountofdatabutton,{
    
    toggle$FSBL <- toggle$FSBL + 1
    show("containthebuttonofthFSBL")
    removeClass("SBL1","borderofFSBLonhidden")
    addClass("SBL1","borderofFSBLonshow")
    
  })
  
  #Action when user click on the minimize-maximize FSBL box button
  observeEvent(input$collapseFSBL,{
    
    toggle$FSBL <- toggle$FSBL + 1
    
  })
  
  observe({
    
    #If toggle$FSBL is even hide the import file options box
    if((toggle$FSBL %% 2) == 0){
      removeClass("collapseFSBL","styleofSBLtogglebtttominimize")
      addClass("collapseFSBL","styleofSBLtogglebtttomaximize")
      hide("SBL1")
      show("SSBL")
      
      #If toggle$FSBL is odd show the import file options box
    }else{
      removeClass("collapseFSBL","styleofSBLtogglebtttomaximize")
      addClass("collapseFSBL","styleofSBLtogglebtttominimize")
      show("SBL1")
      hide("SSBL")
    }
    
  })
  
  #2###########SELECTING-FEATURES-TO-RESEARCH-FOR-THE-OPTIMAL-MODEL############

  #2. - INPUTS

  #2.1 - Time series and scales options
  source(file = "www/R_scripts/SecondSBL/2._Server/Inputs/2.1_Time_series_and_scales_options.R", local = T)

  #2.2 - Training vectors options
  source(file = "www/R_scripts/SecondSBL/2._Server/Inputs/2.2_Training_vectors_options.R", local = T)

  #2.3 - Neurons in the LSTM layer
  source(file = "www/R_scripts/SecondSBL/2._Server/Inputs/2.3_Neurons_in_the_LSTM_layer.R", local = T)
  
  #2.4 - Training and testing options
  source(file = "www/R_scripts/SecondSBL/2._Server/Inputs/2.4_Training_and_Testing_options.R", local = T)
  
  #2. - OUTPUTS
  #2.1 - Time series and scales options
  output$timeseries <- renderUI({tags$iframe(src = "Time_series.html",
                                             width = "100%",
                                             height = "520em",
                                             frameBorder = "0")})

  #2.2 - Training vectors options
  output$trainigvectors <- renderUI({tags$iframe(src = "Training_vectors.html",
                                                 width = "100%",
                                                 height = "520em",
                                                 frameBorder = "0")})

  #2.3 - Neurons in the LSTM layer
  output$neuronslstm <- renderUI({tags$iframe(src = "Neurons.html",
                                              width = "100%",
                                              height = "520em",
                                              frameBorder = "0")})
  
  #2.4 - Training and testing options
  output$trainingandtesting <- renderUI({tags$iframe(src = "Training_and_Testing.html",
                                                        width = "100%",
                                                        height = "520em",
                                                        frameBorder = "0")})
  
  ###################################RESULTS########################################
  
  #Action on download button
  output$download <- downloadHandler(
    filename = function(){
      "Results.zip"
      },
    content = function(file){
      
      files <- c()
      
      for (i in 1:length(mylist$files)) {
        files[i] <- paste0('www/', session$token,"/",mylist$files[i])
      }
      
      zipr(zipfile = file, files = files)
      },
    
    contentType = "application/zip"
  )
  
  ########################################## END ########################################
  
  session$onSessionEnded(function(){
    unlink(paste0("www/",session$token), recursive = TRUE)
  })
  
}

