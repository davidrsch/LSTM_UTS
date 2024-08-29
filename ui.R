
###############################################################################
##                                                                           ##
##                           Shiny App - UI code                             ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

library(shiny)
library(shinyalert)
library(shinybusy)
library(shinyjs)
library(shinythemes)
library(shinyWidgets)
library(readxl)
library(readr)
library(tools)
library(DT)
library(ggplot2)
library(tseries)
library(scales)
library(keras)
library(tensorflow)
library(Metrics)
#library(xlsx)
library(zip)
library(jsonlite)
library(rmarkdown)

ui <- fluidPage(

  useShinyjs(),
  useShinyalert(force = T),
  
  #####################################HEAD#######################################
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css")
    ),
  
  #1###################IMPORTING_DATABASE_AND_SELECTING_VARIABLES##############
  div(style = "position:relative; margin-top: 2em",
  div(id = "Firstdiv",
    style = "position: relative; margin:0 -1em 0 -1em",
      div(id = "containthebuttonofthFSBL",
          class = "styleofheaderFSBL styleofheaderFSBLtominimize",
          actionButton("collapseFSBL",label = "",
                       class = "styleofSBLtogglebtt styleofSBLtogglebtttominimize")),
      div(id = "SBL1",
        sidebarLayout(
          
          #1.-INPUTS
          sidebarPanel(fluid = T,
                       
                       #1.1 - To upload file
                       HTML('
                       <div class="form-group shiny-input-container">
                         <label class="control-label" for="file">
                           <h4 style = "color:white">
                             <strong>Upload database</strong>
                           </h4>
                         </label>
                         <div class="input-group">
                           <label class="input-group-btn input-group-prepend">
                             <span class="btn btn-default btn-file">
                               Browse...
                               <input id="file" name="file" type="file" style="display: none;"/>
                             </span>
                           </label>
                           <input id = "file_text" type="text" class="form-control" placeholder = "No file selected" readonly="readonly"/>
                         </div>
                         <div id="file_progress" class="progress active shiny-file-input-progress">
                           <div class="progress-bar"></div>
                         </div>
                       </div>
                            '),
                       
                       #1.2 - Imported file options
                       #Imported file options box
                       uiOutput("importedfileopt",
                                style = "margin-left: -1em; margin-right: -1em"),
                       
                       #1.3 - Select the date variable and the variable to forecast
                       #Select variables box
                       uiOutput("selectvariables",
                                style = "margin-left: -1em; margin-right: -1em;"),
                       
                       #1.4 - Select amount of variable to use
                       #Select amount of data to use box
                       uiOutput("selectamounttousebox",
                                style = "margin-left: -1em; margin-right: -1em;"),
                       
                       #Style of sidebar panel
                       style = "background-color: rgb(27, 137, 255)"
                       
                       ),
          
          #1.- OUTPUTS
          mainPanel(
            
            #1.1- Upload file outputs
            wellPanel(
              
              #1.1.1- Starting application and on error uploading file
              uiOutput("fileupload"),
              
              #1.1.2- Uploaded database table
              #Uploaded database table box
              uiOutput("uploaded_database",
                       style = "margin-left: -1em; margin-right: -1em"),
              
              #1.2 - Selected variables plot
              #Selected variables plot box
              uiOutput("plotselectedvariables",
                       style = "margin-left: -1em; margin-right: -1em"),
              
              #Style of the well panel inside the main panel
              style = "background-color: rgb(27,137,255)"
              
              )
            )
          ),
        
        #Style the content of the FSBL content
        style = "background-color: rgb(183,217,255); padding: 1em 1em 0 1em",
        class = "borderofFSBLonhidden"
        ),
      div(
      style = "width:100%; clear: both; display: inline-block")
      ),

  #2###########SELECTING-FEATURES-TO-RESEARCH-FOR-THE-OPTIMAL-MODEL############
  
  div( id = "SSBL",
       sidebarLayout(
         
         #2. - INPUTS
         
         sidebarPanel(
           
           #2.1 - Time series and scales options
           #Time series and scales options box
           uiOutput("ts_and_scales_opt_box",
                    style = "margin-left: -1em; margin-right: -1em;"),
           
           #2.2 - Training vectors options
           #Training vectors options box
           uiOutput("tv_opt_box",
                    style = "margin-left: -1em; margin-right: -1em;"),
           
           #2.3 - Neurons in the LSTM layer
           #LSTM neurons options box
           uiOutput("lstm_neurons_box",
                    style = "margin-left: -1em; margin-right: -1em;"),
           
           #2.4 - Training and testing options
           uiOutput("trainingandtestingoptbox",
                    style = "margin-left: -1em; margin-right: -1em;"),
           
           #Style of the sidebarPanel of SSBL
           style = "background-color: rgb(108,179,255); height: 43em; margin: 0.5em 0 0.5em 0.5em "
           
           ),
         
         #2. - OUTPUTS
         mainPanel(
           tabsetPanel(
             id = "Proposal_tabsetPanel",
             
             #2.1 - Time series and scales options
             tabPanel(
               h4(strong("Time series")),
               uiOutput("timeseries"),
               value = "TS_and_scales_opt_tabPanel"),
             
             #2.2 - Training vectors options
             tabPanel(
               h4(strong("Training vectors")),
               uiOutput("trainigvectors"),
               value = "Training_vectors_tabPanel"),
             
             #2.3 - Neurons in the LSTM layer
             tabPanel(
               h4(strong("LSTM")),
               uiOutput("neuronslstm"),
               value = "Neurons_LSTMlayer_tabPanel"),
             
             #2.4 - Training and testing options
             tabPanel(
               h4(strong("Traning & Testing")),
               uiOutput("trainingandtesting"),
               value = "Training_and_testing_options_tabPanel")
             ),
           
           style = "padding: .5em 0 0 0"
           )
         ),
       style = "background-color:white; border-left: 3em solid rgb(27, 137, 255);
       padding:0 0 0 0; margin: 0 0 0 -1em"
       ),
  
  #####################################RESULTS######################################
  div(id = "downloaddiv",
      style = "background-color: rgb(27,137,255); margin: -1em; height: 43em; padding: 15% 15% 0 15%",
      h2(
      "Results are ready for download. The zip file includes the LSTM networks model, whit extension .hdf5, and a report of the obtained results.",
      style = "text-align:center; color: white; font-size: 1.5em"),
      downloadButton("download", style = "margin: 0 0 0 43%")
  )
  )
  )
