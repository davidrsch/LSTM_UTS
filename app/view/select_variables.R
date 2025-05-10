box::use(
  shiny.fluent[Dropdown.shinyInput, reactOutput, renderReact, Stack],
  shiny.fluent[updateDropdown.shinyInput],
  shiny[moduleServer, NS, observeEvent, reactive],
  tibble[is_tibble],
)

box::use(
  app / logic / get_options[get_options],
  app / logic / make_card[make_card],
)

# This is the module for the select variables card.
# The UI is render dynamically from server depending on the data
# obtained from the imported file.
#' @export
ui <- function(id) {
  ns <- NS(id)

  reactOutput(ns("import_variables"))
}

# The server side of this module receive additional parameters as
# data from import_file, [page_button_status, de_prev_button and
# de_next_button] from page_buttons.
# - Render UI based in if the data imported is a tibble. The card
# rendered has two dropdowns one for a sequence variable and another
# one for a variable to forecast.
# - Set event based on sequence variable selector to disable that
# variable in forecast variable selector.
# - Set event based on selecting a variable in forecast selector to
# show, enable or disable page buttons using reactive values from
# page_buttons.
# - Set event to hide or show page buttons based on if the data
# imported is a tibble.
#' @export
server <- function(
  id,
  data,
  page_button_status,
  de_prev_button,
  de_next_button
) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Defining Select Variables to render only if data is imported
    output$import_variables <- renderReact({
      if (is_tibble(data())) {
        names <- c("", names(data()))
        options <- get_options(names)

        make_card(
          "Select variables",
          Stack(
            tokens = list(childrenGap = "10px"),
            Dropdown.shinyInput(
              ns("sequence_variable"),
              label = "Sequence variable",
              options = options,
              value = "",
              `data-testid` = "sequence_variable",
              calloutProps = list(
                `data-testid` = "sequence_variable-callout"
              )
            ),
            Dropdown.shinyInput(
              ns("forecast_variable"),
              label = "Forecast variable",
              options = options,
              value = "",
              required = TRUE,
              `data-testid` = "forecast_variable",
              calloutProps = list(
                `data-testid` = "forecast_variable-callout"
              )
            )
          ),
          style = "max-height: 320px; background-color: white;",
          is_contained = TRUE
        )
      }
    })

    # Disabling options in forecast variable depending in
    # sequence variable selected
    observeEvent(c(input$sequence_variable, data()), {
      if (is_tibble(data()) & !is.null(input$sequence_variable)) {
        names <- c("", names(data()))
        options <- get_options(names, input$sequence_variable)
        updateDropdown.shinyInput(
          inputId = "forecast_variable",
          options = options,
          value = ""
        )
      }
    })

    # Showing or not page buttons depending on if forecast variable is selected
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

    # Hide or show page buttons based on if the data imported is
    # a tibble
    observeEvent(data(), {
      if (!is_tibble(data()) | is.null(data())) {
        page_button_status("hide")
      }
    })

    reactive(
      list(
        sequence_variable = input$sequence_variable,
        forecast_variable = input$forecast_variable
      )
    )
  })
}
