box::use(
  shiny.fluent[Label, Pivot, PivotItem],
  shiny[div, moduleServer, NS, observeEvent, reactive, tags],
  stringr[str_split_i],
)

box::use(
  app/logic/constants[file_formats],
  app/logic/make_card[make_card],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  div(
    style = "padding: 0 28px 28px 28px; background-color: white;",
    class = "ms-depth-8",
    Pivot(
      PivotItem(
        headerText = "Transformations",
        tags$iframe(
          src = "static/transformations.html",
          width = "100%%",
          height = "450px",
          frameBorder = "0")),
      PivotItem(
        headerText = "Training vectors", 
        tags$iframe(
          src = "static/training_vectors.html",
          width = "100%",
          height = "450px",
          frameBorder = "0")),
      PivotItem(headerText = "LSTM", Label("LSTM")),
      PivotItem(headerText = "Training & Testing", Label("Training & Testing"))
    )  
  )    
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  })
}