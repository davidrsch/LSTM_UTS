box::use(
  dplyr[select],
  DT[dataTableOutput, renderDataTable],
  shiny[div, moduleServer, NS, observeEvent, p, reactive, reactiveVal, tags],
  shiny.fluent[PrimaryButton.shinyInput],
  stringr[str_split_i],
)

box::use(
  app/logic/determine_iterations[determine_iterations],
  app/view/make_modal,
)

# Error format modal ui
#' @export
ui <- function(id) {
  ns <- NS(id)

  make_modal$ui(ns("make_modal"))
}

#' @export
server <- function(id, transformations, scales, horizon, inp_amount, lstm, epoch, tests) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Stablishing condition to show the modal
    modal_visible <- reactiveVal(FALSE)

    # Getting iterations properties
    iterations <- reactiveVal("")
    observeEvent(modal_visible(), {
      if (modal_visible()) {
        iterations(
          determine_iterations(
            transformations = transformations,
            scales = scales,
            horizon = horizon,
            inp_amount = inp_amount,
            lstm = lstm,
            epoch = epoch,
            tests = tests)
        )
      } else {
        iterations("")
      }
    })

    output$iterations_table <- renderDataTable({
      if (all(iterations() != "")) {
        iterations()  |> 
          select(-tests)
      }
    },
    filter = "top",
    options = list(
      lengthChange = FALSE,
      pageLength = 5,
      dom = "tip"
    ),
    server = TRUE)
    
    # Creating modla using make_modal module
    observeEvent(modal_visible(), {
      if (modal_visible()) {
        make_modal$server(
          "make_modal",
          is_open = modal_visible,
          title = "Warning",
          content = div(
            p("You will excecute ", iterations()$tests[[1]], " tests of ", dim(iterations())[1], " models. ",
           "Modify the previous form or filter if you whish to modify the models to test."),
            tags$br(),
            dataTableOutput(ns("iterations_table")),
            tags$br(),
            div(
              style = "display: flex; justify-content: center;",
              PrimaryButton.shinyInput(
                ns("startbutton"),
                text = "Start"
              )
            )
          ),
          status = "warning")
      }
    })
    
    reactive(modal_visible)

  })
}