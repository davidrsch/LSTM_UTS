box::use(
  dplyr[if_else, mutate],
  shiny.fluent[Dropdown.shinyInput, reactOutput, renderReact, Stack, updateDropdown.shinyInput],
  shiny[moduleServer, NS, observeEvent],
  tibble[is_tibble, tibble],
)

box::use(
  app/logic/make_card[make_card],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  reactOutput(ns("import_variables"))
}

#' @export
server <- function(id, data, page_button_status, de_prev_button, de_next_button) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # Defining Select Variables to render only if data is imported
    output$import_variables <- renderReact({
      if (is_tibble(data())) {

        names <- names(data())
        options <- tibble(
          key = names,
          text = names) |>
          split(seq_along(names)) |>
          unname() |>
          lapply(function(x) {
            as.list(x)})

        make_card(
          "Select variables",
          Stack(
            tokens = list(childrenGap = "10px"),
            Dropdown.shinyInput(
              ns("sequence_variable"),
              label = "Select the sequence variable",
              options = options
            ),
            Dropdown.shinyInput(
              ns("forecast_variable"),
              label = "Select the variable to forecast",
              options = options
            )
          ),
          style = "max-height: 320px;",
          is_contained = TRUE
        )
      }

    })

    # Disbling options in forecast variable depending in
    # sequence variable selected
    observeEvent(input$sequence_variable, {
      names <- names(data())
      options <- tibble(
        key = names,
        text = names) |>
        mutate(
          disabled = if_else(key == input$sequence_variable, TRUE, FALSE)
        ) |>
        split(seq_along(names)) |>
        unname() |>
        lapply(function(x) {
          as.list(x)})
      updateDropdown.shinyInput(
        inputId = "forecast_variable",
        options = options,
        value = ""
      )
    })

    # Showing or not page buttons deppending on if forecast variable is selected
    # or not
    observeEvent(input$forecast_variable, {
      if (is.null(input$forecast_variable) | is.na(input$forecast_variable)) {
        page_button_status("hide")
      } else if (input$forecast_variable == "") {
        page_button_status("hide")
      } else {
        page_button_status("show")
        de_next_button("enable")
        de_prev_button("disable")
      }
    })

    observeEvent(data(), {
      if (!is_tibble(data()) | is.null(data())) {
        page_button_status("hide")
      }
    })

  })
}
