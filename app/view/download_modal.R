box::use(
  shiny.fluent[PrimaryButton.shinyInput, Stack],
  shiny[div, moduleServer, NS, observeEvent, p],
  shiny[reactive, reactiveVal],
)

box::use(
  app/view/make_modal,
)

# This module defines the modal that appears when successfully finishing
# computation
#' @export
ui <- function(id) {
  ns <- NS(id)

  make_modal$ui(ns("make_modal"))
}

# The server of this module receives as additional parameter the
# results of the computation.
# - Defines the Boolean reactiveVal that defines modal visibility
# and the observeEvent that modify it based on computations finished.
# - Defines modal using make_modal module
# - Defines the download buttons functionality.
# Returns modal visibility
#' @export
server <- function(id, results) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Stablishing condition to show the modal
    modal_visible <- reactiveVal(FALSE)

    observeEvent(results(), {
      if (results() != "") {
        modal_visible(TRUE)
      } else {
        modal_visible(FALSE)
      }
    })

    # Creating modal using make_modal module
    make_modal$server(
      "make_modal",
      is_open = modal_visible,
      title = "Success",
      content = div(
        p(
          "Tests have ended. Results are going to be download as a",
          " .RData file that you can analyze using the tool available here."
        ),
        Stack(
          horizontal = TRUE,
          horizontalAlign = "center",
          PrimaryButton.shinyInput(
            ns("downloadButton"),
            text = "Download",
            iconProps = list(iconName = "Download")
          )
        )
      ),
      status = "success"
    )

    # Define download button functionality
    observeEvent(input$downloadButton, {
      fname <- paste0("tests_results", Sys.Date(), ".RData")
      results_test <- results()
      save(results_test, file = fname)
    })

    reactive(modal_visible)

  })
}
