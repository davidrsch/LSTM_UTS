box::use(
  shiny[div, moduleServer, NS, renderUI, tags, uiOutput, fileInput],
  ./logic/make_card[make_card],
  shiny.fluent[fluentPage, Stack, Dropdown.shinyInput,
    Checkbox.shinyInput, TextField.shinyInput],
  DT[dataTableOutput, renderDataTable],
  readr[read_csv, read_tsv],
  readxl[read_excel],
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
          Dropdown.shinyInput(
            ns("format"),
            label = "File format",
            options = list(
              list(key = "csv", text = "CSV"),
              list(key = "tsv", text = "TSV"),
              list(key = "xlsx", text = "Excel"))),
          Checkbox.shinyInput(
            ns("header"),
            label = "Has header?",
            value = TRUE),
          TextField.shinyInput(
            ns("delimiter"),
            label = "Delimiter",
            value = ","),
          TextField.shinyInput(
            ns("decimal_point"),
            label = "Decimal point",
            value = ".")  
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
    style = "background-color:white"
  )  
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$data_table <- renderDataTable({
      if (!is.null(input$file)) {
        file_path <- input$file$datapath
        format <- input$format
  
        if (format == "csv") {
          data <- read_csv(file_path, col_names = input$header, delim = input$delimiter, decimal = input$decimal_point)
        } else if (format == "tsv") {
          data <- read_tsv(file_path, col_names = input$header, delim = input$delimiter, decimal = input$decimal_point)
        } else if (format == "xlsx") {
          data <- read_excel(file_path, col_names = input$header)
        }
  
        data
      }
    })
  })
}
