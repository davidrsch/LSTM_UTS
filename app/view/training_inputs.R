box::use(
  shiny.fluent[Dropdown.shinyInput, Stack, Text],
  shiny[moduleServer, NS, observeEvent, reactive],
  stringr[str_split_i],
)

box::use(
  app/logic/constants[file_formats],
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
      Dropdown.shinyInput(
        inputId = "transformation",
        text = "Transformation"
      ),
      Dropdown.shinyInput(
        inputId = "scale",
        text = "Scale"
      ),
      Text(
        variant = "xLarge",
        "Training vectors",
        block = TRUE),
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