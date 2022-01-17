
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

output$importedfileopt <- renderUI({
  tagList(
    div(class = "divcontainingbox",
      div(class = "headerofthedivcontainingbox",
          h4(strong("Imported file"), class = "titleofheader"),
          actionButton("importedfileopboxtogglebtt", label = "",
                       class = "buttonofheaderminimize")
      ),
      div(
      id = "imported_file_option_box",
      
      #1.2.1 - If the dataframe has header or not
      prettyCheckbox("header",
                     "Header",
                     T,
                     status = "primary",
                     icon = icon("check")),
      
      #1.2.2 - To select the delimiter for the csv or tsv files
      pickerInput(inputId = "delimiter",
                  label = "Select the delimiter",
                  c("Comma" = ",",
                    "Semicolon" = ";",
                    "Tab" = "\t",
                    "Whitespace" = " "),
                  options = pickerOptions(style = "btn-primary")),
      
      #1.2.3 - To select the decimal mark in csv or tsv files
      pickerInput(inputId = "dm",
                  label = "Select the decimal mark",
                  c("." = ".",
                    "," = ","),
                  options = pickerOptions(style = "btn-primary")),
      
      #1.2.4 - Button to hide imported file options when user
      #select de options
      actionBttn("fileoptionbutton", "OK", color = "primary",
                 style = "fill",block = T, size = "sm"),
      
      div(style = "height:1em"),
      
      style = "margin: 1em 0 0 0"
      )
    )
  )
})

#Reactive value to store if collapse or not a box
toggle <- reactiveValues()
#Reactive value to store if collapse or not imported file box
toggle$impfilebox <- 1
#Reactive value to store if collapse or not the select variable box
toggle$selecvariablebox <- 1
#Reactive value to store if collapse or not the amount of data to use box
toggle$amountofdatabox <- 1
#Reactive value to store if collapse or not the uploaded database table box
toggle$uploadeddatabasetable <- 1
#Reactive value to store if collapse or not the selected variables box
toggle$plotofselectedvariables <- 1


#Action when user clicks on the OK button of the imported file option box
observeEvent(input$fileoptionbutton,{
  #Ad 1 to togglr$impfilebox to minimize
  toggle$impfilebox <- toggle$impfilebox + 1
  
  #If select variable box is hidden, it give the value to toggle$selecvariablebox to
  #show it
  if((toggle$selecvariablebox %% 2) == 0){
    toggle$selecvariablebox <- toggle$selecvariablebox + 1
  }
  
  })

#Action when user click on the minimize-maximize imported file option box button
observeEvent(input$importedfileopboxtogglebtt,{
  #Ad 1 to togglr$impfilebox to minimize or maximize
  toggle$impfilebox <- toggle$impfilebox + 1
  
  #If the select variables box and the amount of data box are shown,  
  #it give the values to reactive values toggle to hidden them
  if((toggle$selecvariablebox %% 2) != 0){
    toggle$selecvariablebox <- toggle$selecvariablebox + 1
  }
  
  if((toggle$amountofdatabox %% 2) != 0){
    toggle$amountofdatabox <- toggle$amountofdatabox + 1
  }

})


#Conditional to show or hide the "Import file options box" depending on 
#toggle$impfilebox value
observe({
  
  #If toggle$impfilebox is even hide the import file options box
  if((toggle$impfilebox %% 2) == 0){
    removeClass("importedfileopboxtogglebtt","buttonofheaderminimize")
    addClass("importedfileopboxtogglebtt","buttonofheadermaximize")
    hide("imported_file_option_box")
  
    #If toggle$impfilebox is odd show the import file options box
    }else{
      removeClass("importedfileopboxtogglebtt","buttonofheadermaximize")
      addClass("importedfileopboxtogglebtt","buttonofheaderminimize")
      show("imported_file_option_box")
     }
})

#Hiden as default feature to the imported file options output and to the options
#delimiter and decimal mark
observe({
 
  hide("importedfileopt")
  hide("delimiter")
  hide("dm")
   
})


#To hide or show the Imported file options box 
#if a file with the proper extension is imported
observeEvent(input$file, {
  
  #Establish imported file options box as show when a file is imported 
  toggle$impfilebox <- 1
  
  #Establish select variable box and amount of data box as hidden when a file is
  #imported
  toggle$selecvariablebox <- 2
  toggle$amountofdatabox <- 2
  
  #If a file with the proper extension is imported show the imported file options
  if(is.element(file_ext(input$file$datapath), readall)){
    show("importedfileopt")
    
    #If a file that need delimiter and decimal mark parameters is imported show them
    if(is.element(file_ext(input$file$datapath), readdelim)){
      show("delimiter")
      show("dm")
      }
    
    #If a file that does not need delimiter and decimal mark parameters is imported
    #hide them
    if(is.element(file_ext(input$file$datapath), readexcel)){
      hide("delimiter")
      hide("dm")}
    
    #If a file with another extension is imported keep imported file options hidden or
    #hide it
    }else{
     hide("importedfileopt")
    }
})