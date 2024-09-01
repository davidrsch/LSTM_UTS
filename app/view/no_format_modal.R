box::use(
  shiny[div, moduleServer, NS, observeEvent, p, reactiveVal, tags],
  stringr[str_split_i],
)

box::use(
  app/logic/constants[file_formats],
  app/view/make_modal,
)

# Error format modal ui
#' @export
ui <- function(id) {
  ns <- NS(id)

  make_modal$ui(ns("make_modal"))
}

#' @export
server <- function(id, imported_path) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # Stablishing condition to show the modal
    modal_visible <- reactiveVal(FALSE)
    observeEvent(imported_path(), {
      file_path <- imported_path()
      if (!is.null(file_path)) {
        format <- str_split_i(file_path$datapath, "\\.", -1)
        if (!is.element(format, file_formats[["extention"]])) {
          modal_visible(TRUE)
        } else {}
      }
    })
    # Creating modla using make_modal module
    make_modal$server(
      "make_modal",
      is_open = modal_visible,
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
