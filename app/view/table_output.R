box::use(
  DT[dataTableOutput, renderDataTable],
  readr[locale, read_delim],
  readxl[read_excel],
  shiny[moduleServer, NS, observeEvent, reactive, reactiveVal],
  stringr[str_split_i],
)

box::use(
  app/logic/constants[file_formats],
  app/logic/make_card[make_card],
)

# Defining UI of the module
#' @export
ui <- function(id) {
  ns <- NS(id)

  make_card(
    "",
    dataTableOutput(ns("data_table")),
    is_contained = TRUE,
    style = "background-color: white;"
  )
}

# Defining server side of the module. This module take extra
# parameters like from import inputs (file, header, delimiter,
# decimal_point).
# - Creating reactive Value to store the imported data.
# - Render table of imported data.
# Return the data imported and the data filtered from tables.
#' @export
server <- function(id, file, header, delimiter, decimal_point) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    data_imported <- reactiveVal(array(1:2, 2))
    # Creating table output when importing file with proper format
    output$data_table <- renderDataTable({
      if (!is.null(file())) {
        file_path <- file()$datapath
        format <- str_split_i(file_path, "\\.", -1)

        if (is.element(format, file_formats[["extention"]])) {
          if (is.element(format, file_formats[file_formats$type == "text", ][["extention"]])) {
            data <- read_delim(
              file_path,
              col_names = header(),
              delim = delimiter(),
              locale = locale(decimal_mark = decimal_point()))
          } else {
            data <- read_excel(file_path, col_names = header())
          }
          data_imported(data)
          data
        }
      }
    },
    filter = "top",
    options = list(
      lengthChange = FALSE,
      dom = "tip",
      pageLength = 10
    ))

    observeEvent(file(), {
      if (is.null(file())) {
        data_imported(array(1:2, 2))
      } else {
        file_path <- file()$datapath
        format <- str_split_i(file_path, "\\.", -1)
        if (!is.element(format, file_formats[["extention"]])) {
          data_imported(array(1:2, 2))
        }
      }
    })

    reactive(
      list(
        data_imported = data_imported,
        actual_data = if (!is.null(input$data_table_rows_all)) {
          data_imported()[input$data_table_rows_all, ]
        } else {
          NULL 
        } ))

  })
}
