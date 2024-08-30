box::use(
  shiny[div, moduleServer, NS, p, reactiveVal, observeEvent,
    tags, reactive],
  shiny.fluent[renderReact, reactOutput, Modal, Stack, Text,
    FontIcon, IconButton.shinyInput],
  stringr[str_split_i],
  ../logic/constants[file_formats],
  ./make_modal
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  make_modal$ui(ns("make_modal"))
}

#' @export
server <- function(id, imported_path) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    modalVisible <- reactiveVal(FALSE)
    observeEvent(imported_path(),{
      file_path <- imported_path()
      if (!is.null(file_path)) {
        format <- str_split_i(file_path$datapath,"\\.",-1)
        if (!is.element(format, file_formats)) {
          modalVisible(TRUE)
        }else{}
      }
    })
    
    make_modal$server(
      "make_modal",
      is_open = modalVisible,
      title = "Error",
      content = div(
        p("The allowed file formats are:"),
        tags$ul(
          tags$li("csv"),
          tags$li("tsv"),
          tags$li("xlsx"),
          tags$li("xls")
        )
      ),
      status = "error")
    
    

  })
}
