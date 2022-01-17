
###############################################################################
##                                                                           ##
##                 Shiny App - Imported files options code                   ##
##                Simple implementation of LSTM networks for                 ##
##                    univariate time series forecasting                     ##
##                                                                           ##
##                       Author: David Diaz Rodriguez                        ##
##            ORCID:  https://orcid.org/0000-0002-0927-9795                  ##
##                                                                           ##
###############################################################################

#1.2 - Imported file options

#1.2.1- Imported file name
output$filename <- renderUI({
  tags$h5(tags$strong(input$file$name), align = "center")
})

#1.2.2- Imported file table
#Reactive value to store the imported file

database$df <- data.frame()

#Giving value to reactive database$df in dependency of the imported file
#and the imported file options selected by the user
observeEvent(c(input$file,input$header,input$delimiter,input$dm),{
  if(is.null(input$file$datapath)){}
  else{if(is.element(file_ext(input$file$datapath), readdelim))
    database$df <- read_delim(input$file$datapath,
                              delim = input$delimiter,
                              col_names = input$header,
                              locale = locale(decimal_mark = input$dm))
  if(is.element(file_ext(input$file$datapath), readexcel))
    database$df <- read_excel(input$file$datapath,
                              col_names = input$header)}
})

#Rendering the imported database stored in reactive value
output$files <- renderDataTable({
  datatable(database$df,
            options = list(searching = F,
                           scrollX = T,
                           compact = F),
            editable = "cell",
            class = "nowrap hover order-column")
})

#To generate the upload database's table
#Box of upload database's table
output$uploaded_database <- renderUI({
  tagList(
    div(class = "divcontainingbox",
        div(class = "headerofthedivcontainingbox",
            h4(strong("Uploaded database"), class = "titleofheader"),
            actionButton("tableofuploadeddatabasetogglebtt",label = "",
                         class = "buttonofheaderminimize")
        ),
        
        div(
          id = "uploaded_database_table_box",
          
          #1.2.1- Imported file name
          uiOutput("filename"),
          
          #1.2.2- Imported file table
          dataTableOutput("files"),
          
          div(style = "height:1em"),
          
          style = "margin: 1em 0 0 0"
          )
        )
    )
})

#Action when user click on the minimize-maximize uploaded database table box button
observeEvent(input$tableofuploadeddatabasetogglebtt,{
  
  toggle$uploadeddatabasetable <- toggle$uploadeddatabasetable + 1
  
  #If the selected variables plot is shown it give the values to reactive values
  #toggle to hide it
  if((toggle$plotofselectedvariables %% 2) != 0){
    toggle$plotofselectedvariables <- toggle$plotofselectedvariables + 1
  }
  
})

observe({
  
  #If toggle$uploadeddatabasetable is even hide the uploaded database table box
  if((toggle$uploadeddatabasetable %% 2) == 0){
    removeClass("tableofuploadeddatabasetogglebtt","buttonofheaderminimize")
    addClass("tableofuploadeddatabasetogglebtt","buttonofheadermaximize")
    hide("uploaded_database_table_box")
    
    #If toggle$uploadeddatabasetable is odd show the uploaded database table box
    }else{
      removeClass("tableofuploadeddatabasetogglebtt","buttonofheadermaximize")
      addClass("tableofuploadeddatabasetogglebtt","buttonofheaderminimize")
      show("uploaded_database_table_box")
      }
})

#To hide or show the Database's table box and render the main panel
#if a file with the proper extension is imported
observe({
  if(is.null(input$file)){
    hide("uploaded_database")
  }
  else if(is.element(file_ext(input$file$datapath), readall)){
    show("uploaded_database")}
})