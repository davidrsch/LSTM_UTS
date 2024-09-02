box::use(
  shiny.fluent[fluentPage, Stack],
  shiny[div, moduleServer, NS, observeEvent, reactive, tags],
  shinyjs[hidden, useShinyjs],
)

box::use(
  app/view/import_file,
  app/view/no_format_modal,
  app/view/page_buttons,
  app/view/select_variables,
  app/view/table_output,
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  fluentPage(
    # Defining style
    tags$style(".card { padding: 28px; margin-bottom: 14px; }"),
    useShinyjs(),
    # Definin horizontal layout
    Stack(
      horizontal = TRUE,
      tokens = list(childrenGap = 10),
      # Defining left side of the layout (size: 4)
      div(
        # Defining import file inputs card
        import_file$ui(ns("import_file")),
        # Defining selected variables card ui
        select_variables$ui(ns("select_variables")),
        class = "ms-sm-4 ms-xl-4"
      ),
      # Defining right side of the layout (size: 8)
      # Table output card
      table_output$ui(ns("table_output"))
    ),
    # Defining prev and next buttons
    hidden(page_buttons$ui(ns("page_buttons"))),
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

    # Defining import file inputs card
    imported_file <- import_file$server("import_file")

    # Defining right side of the layout (size: 8)
    # Table output card
    data_imported <- table_output$server(
      "table_output",
      file = reactive(imported_file()$file),
      header = reactive(imported_file()$header),
      delimiter = reactive(imported_file()$delimiter),
      decimal_point = reactive(imported_file()$decimal_point)
    )

    # Defining prev and next buttons
    pn_buttons <- page_buttons$server("page_buttons")

    # Defining selected variables card server
    select_variables$server(
      "select_variables",
      data = data_imported,
      page_button_status = pn_buttons()$hs_page_buttons,
      de_prev_button = pn_buttons()$de_prev_button,
      de_next_button = pn_buttons()$de_next_button
    )

    # Defining modals
    # Error format modal server
    no_format_modal$server(
      "no_format_modal",
      imported_path = reactive(imported_file()$file))

  })
}
