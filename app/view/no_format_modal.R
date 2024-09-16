box::use(
  shiny[div, moduleServer, NS, observeEvent, p, reactiveVal, tags],
  stringr[str_split_i],
)

box::use(
  app/logic/constants[file_formats],
  app/view/make_modal,
)

# This module defines the modal that appears when attempting to load
# a file with not accepted extension.
#' @export
ui <- function(id) {
  ns <- NS(id)

  make_modal$ui(ns("make_modal"))
}

# The server of this module receives as additional parameter the
# path of the imported file.
# - Defines the Boolean reactiveVal that defines modal visibility
# and the observeEvent that modify it based on imported_path.
# - Defines modal using make_modal module
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
        if (!is.element(format, file_formats[["extensions"]])) {
          modal_visible(TRUE)
        } else {}
      }
    })

    # Creating modal using make_modal module
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
