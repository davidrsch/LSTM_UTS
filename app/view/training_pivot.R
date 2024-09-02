box::use(
  shiny.fluent[Label, Pivot, PivotItem],
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
    Pivot(
      PivotItem(headerText = "Transformations", Label("Transformations")),
      PivotItem(headerText = "Training vectors", Label("Training vectors")),
      PivotItem(headerText = "LSTM", Label("LSTM")),
      PivotItem(headerText = "Training & Testing", Label("Training & Testing"))
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