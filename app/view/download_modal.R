box::use(
  shiny.fluent[PrimaryButton.shinyInput, Stack],
  shiny[div, downloadButton, downloadHandler, moduleServer, NS, observeEvent],
  shiny[outputOptions, p, tagAppendAttributes],
  shiny[reactive, reactiveVal],
  shinyjs[click, hidden],
)

box::use(
  app/view/make_modal,
)

# This module defines the modal that appears when successfully finishing
# computation
#' @export
ui <- function(id) {
  ns <- NS(id)

  div(
    make_modal$ui(ns("make_modal")),
    hidden(
      downloadButton(
        ns("download"),
        label = ""
      ) |>
        tagAppendAttributes(
          `data-testid` = "download"
        )
    )
  )
}

# The server of this module receives as additional parameter the
# results of the computation.
# - Defines the Boolean reactiveVal that defines modal visibility
# and the observeEvent that modify it based on computations finished.
# - Defines modal using make_modal module
# - Defines the download buttons functionality.
# Returns modal visibility
#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Stablishing condition to show the modal
    m_download_visible <- reactiveVal(FALSE)

    # Define reactive value to store results of computations and observer
    # event to trigger visibility of modal
    results <- reactiveVal("")

    observeEvent(results(), {
      if (all(results() != "")) {
        m_download_visible(TRUE)
      } else {
        m_download_visible(FALSE)
      }
    })

    # Creating modal using make_modal module
    make_modal$server(
      "make_modal",
      name = "download_modal",
      is_open = m_download_visible,
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
            ns("download_button"),
            text = "Download",
            iconProps = list(iconName = "Download"),
            `data-testid` = "download_button"
          )
        )
      ),
      status = "success"
    )

    # Define download button functionality
    observeEvent(input$download_button, {
      click("download")
    })

    output$download <- downloadHandler(
      filename = function() {
        paste0("test_results_", Sys.Date(), ".RData")
      },
      content = function(file) {
        results_tests <- results()
        save(results_tests, file = file)
      }
    )

    outputOptions(output, "download", suspendWhenHidden = FALSE)

    reactive(
      list(
        results = results,
        visibility = m_download_visible
      )
    )

  })
}
