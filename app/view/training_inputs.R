box::use(
  shiny.fluent[Dropdown.shinyInput, SpinButton.shinyInput, Stack, Text, TextField.shinyInput],
  shiny[moduleServer, NS, observeEvent, reactive],
  stringr[str_split_i],
)

box::use(
  app/logic/constants[file_formats, transformations, scales],
  app/logic/make_card[make_card],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  make_card(
    "",
    Stack(
      tokens = list(childrenGap = 10),
      Text(
        variant = "xLarge",
        "Transformations",
        block = TRUE),
      Stack(
        horizontal = TRUE,
        tokens = list(childrenGap = "10%"),
        Dropdown.shinyInput(
          inputId = "transformation",
          label = "Transformation",
          options = transformations,
          multiSelect = TRUE,
          styles = list(
            root = list(
              'max-width' = "45%",
              'min-width' = "45%"))
        ),
        Dropdown.shinyInput(
          inputId = "scale",
          label = "Scale",
          options = scales,
          multiSelect = TRUE,
          styles = list(
            root = list(
              'max-width' = "45%",
              'min-width' = "45%"))
        )
      ),
      Text(
        variant = "xLarge",
        "Training vectors",
        block = TRUE),
      Stack(
        horizontal = TRUE,
        tokens = list(childrenGap = "10%"),
        SpinButton.shinyInput(
          inputId = "horizon",
          label = "Temporal horizon:",
          labelPosition = "top",
          styles = list(
            root = list(
              'max-width' = "45%",
              'min-width' = "45%"))
        ),
        TextField.shinyInput(
          inputId = "inp_amount",
          label = "Input amounts:",
          description = 'Separete amounts using commas: ","'
        )
      ),
      Text(
        variant = "xLarge",
        "LSTM",
        block = TRUE),
      Text(
        variant = "xLarge",
        "Training & Testing",
        block = TRUE)
    ),
    style = "max-height: 320px; background-color: white;",
    is_contained = TRUE
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  })
}