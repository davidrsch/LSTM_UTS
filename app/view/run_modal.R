box::use(
  dplyr[mutate, select],
  DT[DTOutput, renderDT],
  shiny.fluent[PrimaryButton.shinyInput],
  shiny[div, moduleServer, NS, observeEvent, p, reactive, reactiveVal, tags],
  shinycssloaders[hidePageSpinner, showPageSpinner],
)

box::use(
  app/logic/determine_iterations[determine_iterations],
  app/logic/process[process],
  app/logic/test_id_datatables[test_id_datatables],
  app/view/make_modal,
)

# Run modal UI
#' @export
ui <- function(id) {
  ns <- NS(id)

  make_modal$ui(ns("make_modal"))
}

# The server of this module takes as additional inputs the data imported,
# the sequence and forecast variables selected, the parameters selected
# in training inputs (transformations, scales, horizon, inp_amount, lstm,
# epoch, tests) and d_modal the visibility status of the download modal.
# - Define condition to show the modal
# - Store all possible combinations of training inputs in a data frame
# - Create table of all possible combinations
# - Create modal with table and start computation button
# - Defining reactive value to store results and observe on start button
# to do the computations, and display a spinner.
# Return visibility reactive value and results.
#' @export
server <- function(id, data, sequence, forecast, transformations,
                   scales, horizon, inp_amount, lstm, epoch, tests, d_modal,
                   results) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Stablishing condition to show the modal
    m_run_visible <- reactiveVal(FALSE)

    # Getting iterations properties
    iterations <- reactiveVal(list("", ""))
    observeEvent(m_run_visible(), {
      if (m_run_visible()) {
        iterations(
          determine_iterations(
            transformations = transformations(),
            scales = scales(),
            horizon = horizon(),
            inp_amount = inp_amount(),
            lstm = lstm(),
            epoch = epoch(),
            tests = tests()
          )
        )
      } else {
        iterations(list("", ""))
      }
    })

    # Creating table of all possible combinations
    output$iterations_table <- renderDT({
      if (all(iterations() != "")) {
        iterations()  |>
          select(-tests)
      }
    },
    filter = "top",
    options = list(
      lengthChange = FALSE,
      pageLength = 5,
      dom = "tip",
      initComplete = test_id_datatables("iterations")
    ))

    # Creating modal using make_modal module
    make_modal$server(
      "make_modal",
      name = "run_modal",
      is_open = m_run_visible,
      title = "Warning",
      content = div(
        p("You will execute ", iterations()$tests[[1]], " tests of ", dim(iterations())[1],
          " models. Modify the previous form or filter if you whish to modify the",
          " models to test."),
        tags$br(),
        div(
          DTOutput(ns("iterations_table")),
          `data-testid` = "iterations_table"
        ),
        tags$br(),
        div(
          style = "display: flex; justify-content: center;",
          PrimaryButton.shinyInput(
            ns("startbutton"),
            text = "Start",
            `data-testid` = "startbutton"
          )
        )
      ),
      status = "warning"
    )

    # Define observer event to trigger computation and store them in
    # results
    observeEvent(input$startbutton, {
      if (all(iterations() != "")) {
        showPageSpinner(
          caption = "Please wait, this can take several minutes"
        )
        iterations_data <- iterations()[input$iterations_table_rows_all, ] |>
          mutate(
            inp_amount = as.numeric(inp_amount),
            lstm = as.numeric(lstm),
            tests = tests()
          )
        results(
          process(data(), sequence(), forecast(), iterations_data)
        )
        m_run_visible(FALSE)
        d_modal(TRUE)
        hidePageSpinner()
      }
    })

    reactive(
      list(
        m_run_visible = m_run_visible
      )
    )

  })
}
