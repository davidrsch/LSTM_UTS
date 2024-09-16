box::use(
  shiny.fluent[fluentPage],
  shiny[div, moduleServer, NS, reactive],
  shinyjs[useShinyjs],
)

box::use(
  app/view/download_modal,
  app/view/import_file,
  app/view/no_format_modal,
  app/view/page_buttons,
  app/view/run_modal,
  app/view/select_variables,
  app/view/table_output,
  app/view/training_inputs,
  app/view/training_pivot,
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  fluentPage(
    useShinyjs(),

    # Definin horizontal layout
    div(
      class = "ms-Grid-row",
      style = "display: flex; flex-wrap: wrap;",
      # Defining left side of the layout (size: 4)
      div(
        class = "ms-Grid-col ms-sm12 ms-md4",
        div(
          class = "panelcontainer",
          div(
            # Defining training inputs card
            training_inputs$ui(ns("training_inputs")),
            class = "backpanel"
          ),
          div(
            # Defining import file inputs card
            import_file$ui(ns("import_file")),
            # Defining selected variables card ui
            select_variables$ui(ns("select_variables")),
            class = "frontpanel"
          )
        )
      ),
      div(
        class = "ms-Grid-col ms-sm12 ms-md8",
        div(
          class = "panelcontainer",
          div(
            # Defining right side of the layout (size: 8)
            # Training pivot card
            training_pivot$ui(ns("training_pivot")),
            class = "backpanel"
          ),
          div(
            # Table output card
            table_output$ui(ns("table_output")),
            class = "frontpanel"
          )
        )
      )
    ),
    # Defining prev and next buttons
    div(
      class = "ms-Grid-row",
      page_buttons$ui(ns("page_buttons"))
    ),
    # Defining modals
    # Error format modal ui
    no_format_modal$ui(ns("no_format_modal")),
    # Run modal ui
    run_modal$ui(ns("run_modal")),
    # Download modal ui
    download_modal$ui(ns("download_modal")),

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

    # Defining table output card
    data_imported <- table_output$server(
      "table_output",
      file = reactive(imported_file()$file),
      header = reactive(imported_file()$header),
      delimiter = reactive(imported_file()$delimiter),
      decimal_point = reactive(imported_file()$decimal_point)
    )

    # Defining prev and next buttons
    pn_buttons <- page_buttons$server(
      "page_buttons",
      run_modal_state = run_visibility()$modal_visible
    )

    # Defining selected variables card server
    selected_variables <- select_variables$server(
      "select_variables",
      data = data_imported()$data_imported,
      page_button_status = pn_buttons()$hs_page_buttons,
      de_prev_button = pn_buttons()$de_prev_button,
      de_next_button = pn_buttons()$de_next_button
    )

    # Defining training inputs card
    inputs_training <- training_inputs$server(
      "training_inputs",
      run_button_status = pn_buttons()$hs_run_button
    )

    # Defining training pivot card
    training_pivot$server("training_pivot")

    # Defining modals
    # Error format modal server
    no_format_modal$server(
      "no_format_modal",
      imported_path = reactive(imported_file()$file)
    )
    # Run modal server
    run_visibility <- run_modal$server(
      "run_modal",
      data = data_imported()$actual_data,
      sequence = selected_variables()$sequence_variable,
      forecast = selected_variables()$forecast_variable,
      transformations = inputs_training()$transformations,
      scales = inputs_training()$scales,
      horizon = inputs_training()$horizon,
      inp_amount = inputs_training()$inp_amount,
      lstm = inputs_training()$lstm,
      epoch = inputs_training()$epoch,
      tests = inputs_training()$tests,
      d_modal = download_visibility()
    )
    # Download modal server
    download_visibility <- download_modal$server(
      "download_modal",
      results = run_visibility()$results
    )

  })
}
