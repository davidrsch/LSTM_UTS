box::use(
  shiny[div, moduleServer, NS, renderUI, tags, uiOutput, fileInput,
    reactive, observeEvent],
  ./logic/make_card[make_card],
  shiny.fluent[fluentPage, Stack, Checkbox.shinyInput,
    updateCheckbox.shinyInput, TextField.shinyInput,
    updateTextField.shinyInput],
  DT[dataTableOutput, renderDataTable],
  readr[read_delim, locale],
  readxl[read_excel],
  stringr[str_split_i],
  logic/constants[file_formats],
  app/view/no_format_modal
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  
  fluentPage(
    tags$style(".card { padding: 28px; margin-bottom: 28px; }"),
    
    Stack(
      horizontal = T,
      make_card(
        "",
        Stack(
          fileInput(
            ns("file"),
            "Upload a file"),
          tags$br(),
          Checkbox.shinyInput(
            ns("header"),
            label = "Has header?",
            value = TRUE,
            disabled = TRUE),
          tags$br(),
          TextField.shinyInput(
            ns("delimiter"),
            label = "Delimiter",
            value = ",",
            disabled = TRUE),
          tags$br(),
          TextField.shinyInput(
            ns("decimal_point"),
            label = "Decimal point",
            value = ".",
            disabled = TRUE)  
        ),
        size = 4,
        style = "max-height: 320px;"
      ),
      make_card(
        "",
        dataTableOutput(ns("data_table")),
        size = 8
      )
    ),
    no_format_modal$ui(ns("no_format_modal")),
    style = "background-color:white"
  )  
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

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
    
          data  
        } else {}
  
      }
    })

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

    no_format_modal$server(
      "no_format_modal",
      imported_path = reactive(input$file))

  })
}
