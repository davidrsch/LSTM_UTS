box::use(
  shiny[div, moduleServer, NS, renderUI, tags, uiOutput, fileInput,
    reactive, observeEvent, reactiveVal],
  ./logic/make_card[make_card],
  shiny.fluent[fluentPage, Stack, Checkbox.shinyInput,
    updateCheckbox.shinyInput, TextField.shinyInput,
    updateTextField.shinyInput, Text],
  DT[dataTableOutput, renderDataTable],
  readr[read_delim, locale],
  readxl[read_excel],
  stringr[str_split_i],
  logic/constants[file_formats],
  app/view/no_format_modal,
  app/view/import_variables
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluentPage(
    # Defining style
    tags$style(".card { padding: 28px; margin-bottom: 14px; }"),
    # Definin horizontal layout
    Stack(
      horizontal = T,
      tokens = list(childrenGap = 10),
      # Defining left side of the layout (size: 4)
      div(
        # Defining import file inputs card
        make_card(
          "Import file",
          Stack(
            tokens = list(childrenGap = 10),
            fileInput(
              ns("file"),
              "Upload a file"),
            Checkbox.shinyInput(
              ns("header"),
              label = "Has header?",
              value = TRUE,
              disabled = TRUE),
            Stack(
              horizontal = TRUE,
              tokens = list(childrenGap = 10),
              TextField.shinyInput(
                ns("delimiter"),
                label = "Delimiter",
                value = ",",
                disabled = TRUE),
              TextField.shinyInput(
                ns("decimal_point"),
                label = "Decimal point",
                value = ".",
                disabled = TRUE)
            )              
          ),
          style = "max-height: 320px;",
          is_contained = TRUE
        ),
        # Defining selected variables card ui
        import_variables$ui(ns("import_variables")),
        class = "ms-sm-4 ms-xl-4"
      ),
      # Defining right side of the layout (size: 8)
      # Table output card
      make_card(
        "",
        dataTableOutput(ns("data_table")),
        size = 8
      )
    ),
    # Defining modals
    # Error format modal ui
    no_format_modal$ui(ns("no_format_modal")),
    
    # Defining fluent page style
    style = "background-color:white"
  )  
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    data_imported <- reactiveVal(array(1:2,2))
    # Creating table output when importing file with proper format
    output$data_table <- renderDataTable({
      if (!is.null(input$file)) {
        file_path <- input$file$datapath
        format <- str_split_i(file_path,"\\.",-1)

        if (is.element(format, file_formats[["extention"]])) {
          if (is.element(format, file_formats[file_formats$type == "text",][["extention"]])) {
            data <- read_delim(
              file_path, 
              col_names = input$header, 
              delim = input$delimiter, 
              locale = locale(decimal_mark = input$decimal_point))
          } else {
            data <- read_excel(file_path, col_names = input$header)
          }
          data_imported(data)
          data  
        } else {
          #data_imported(array(1:2,2))
        }
  
      }
    })

    # Enabling or disabling inputs depending on the imported file format
    observeEvent(input$file, {
      if (!is.null(input$file)) {
        file_path <- input$file$datapath
        format <- str_split_i(file_path,"\\.",-1)
        
        if (is.element(format, file_formats[["extention"]])) {
          updateCheckbox.shinyInput(
            inputId = "header",
            disabled = FALSE)
          if (is.element(format, file_formats[file_formats$type == "text",][["extention"]])) {
            updateTextField.shinyInput(
              inputId = "delimiter",
              disabled = FALSE
            )
            updateTextField.shinyInput(
              inputId = "decimal_point",
              disabled = FALSE
            )
          } else {
            updateTextField.shinyInput(
              inputId = "delimiter",
              disabled = TRUE
            )
            updateTextField.shinyInput(
              inputId = "decimal_point",
              disabled = TRUE
            )
          }

        } else {
          updateCheckbox.shinyInput(
            inputId = "header",
            disabled = TRUE)
          updateTextField.shinyInput(
            inputId = "delimiter",
            disabled = TRUE
          )
          updateTextField.shinyInput(
            inputId = "decimal_point",
            disabled = TRUE
          )
        }
      } 
    })

    # Defining selected variables card server
    import_variables$server(
      "import_variables",
      data = data_imported
    )

    # Defining modals
    # Error format modal server
    no_format_modal$server(
      "no_format_modal",
      imported_path = reactive(input$file))

  })
}
