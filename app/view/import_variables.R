box::use(
  shiny[NS, moduleServer, observeEvent],
  shiny.fluent[reactOutput, renderReact, Stack, Dropdown.shinyInput,
    updateDropdown.shinyInput],
  ../logic/make_card[make_card],
  tibble[tibble, is_tibble],
  tidyr[nest],
  dplyr[mutate, if_else]
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  reactOutput(ns("import_variables"))
}

#' @export
server <- function(id, data) {
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
          lapply(function(x){as.list(x)})

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
    observeEvent(input$sequence_variable,{
      names <- names(data())
      options <- tibble(
        key = names,
        text = names) |> 
        mutate(
          disabled = if_else(key==input$sequence_variable,T,F)
        ) |> 
        split(seq_along(names)) |> 
        unname() |> 
        lapply(function(x){as.list(x)})
      updateDropdown.shinyInput(
        inputId = "forecast_variable",
        options = options,
        value = ""
      )
    })

  })
}

