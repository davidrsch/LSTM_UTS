box::use(
  shiny.fluent[DefaultButton.shinyInput, fluentPage, reactOutput, renderReact, Stack],
  shiny[div, moduleServer, NS, observeEvent, reactive, reactiveVal, tags],
  shinyjs[hidden, hide, show, useShinyjs],
)

box::use(
  app/view/import_file,
  app/view/no_format_modal,
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
    hidden(reactOutput(ns("page_buttons"))),
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
    output$page_buttons <- renderReact({
      div(
        style = "display: flex; justify-content: space-around;",
        div(
          style = "display: flex;",
          DefaultButton.shinyInput(
            ns("prevtbutton"),
            text = "Previous"
          ),
          div(
            style = "width: 15px;",
          ),
          DefaultButton.shinyInput(
            ns("nextbutton"),
            text = "Next"
          )
        )
      )
    })

    # Hidden or showing page buttons
    hs_page_buttons <- reactiveVal("hide")
    observeEvent(hs_page_buttons(), {
      if (hs_page_buttons() == "hide") {
        hide("page_buttons")
      } else {
        show("page_buttons")
      }
    })

    # Defining selected variables card server
    select_variables$server(
      "select_variables",
      data = data_imported,
      page_button_status = hs_page_buttons
    )

    # Defining modals
    # Error format modal server
    no_format_modal$server(
      "no_format_modal",
      imported_path = reactive(imported_file()$file))

  })
}
