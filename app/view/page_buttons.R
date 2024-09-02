box::use(
  shiny.fluent[DefaultButton.shinyInput, reactOutput, renderReact, updateDefaultButton.shinyInput],
  shiny[div, moduleServer, NS, observeEvent, reactive, reactiveVal],
  shinyjs[hide, show],
)

box::use(
  app/view/import_file,
  app/view/no_format_modal,
  app/view/select_variables,
  app/view/table_output,
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  # Defining prev and next buttons
  reactOutput(ns("page_buttons"))
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Defining prev and next buttons
    output$page_buttons <- renderReact({
      div(
        style = "display: flex; justify-content: space-around;",
        div(
          style = "display: flex;",
          DefaultButton.shinyInput(
            ns("prevtbutton"),
            text = "Previous",
            disabled = TRUE
          ),
          div(
            style = "width: 15px;",
          ),
          DefaultButton.shinyInput(
            ns("nextbutton"),
            text = "Next",
            disabled = FALSE
          )
        )
      )
    })

    # Defining reactive value hidden or showing page buttons
    hs_page_buttons <- reactiveVal("hide")
    observeEvent(hs_page_buttons(), {
      if (hs_page_buttons() == "hide") {
        hide("page_buttons")
      } else {
        show("page_buttons")
      }
    })

    # Defining reactive value disable or enable previous buttons
    de_prev_button <- reactiveVal("")
    observeEvent(de_prev_button(), {
      if (de_prev_button() == "enable") {
        updateDefaultButton.shinyInput(
          inputId = "prevtbutton",
          disabled = FALSE
        )
      } else if (de_prev_button() == "disable") {
        updateDefaultButton.shinyInput(
          inputId = "prevtbutton",
          disabled = TRUE
        )
      }
    })

    # Defining reactive value disable or enable next buttons
    de_next_button <- reactiveVal("")
    observeEvent(de_next_button(), {
      if (de_next_button() == "enable") {
        updateDefaultButton.shinyInput(
          inputId = "nextbutton",
          disabled = FALSE
        )
      } else if (de_next_button() == "disable") {
        updateDefaultButton.shinyInput(
          inputId = "nextbutton",
          disabled = TRUE
        )
      }
    })

    observeEvent(input$prevtbutton, {
      de_next_button("enable")
      de_prev_button("disable")
    })

    observeEvent(input$nextbutton, {
      de_next_button("disable")
      de_prev_button("enable")
    })

    reactive(
      list(
        hs_page_buttons = hs_page_buttons,
        de_prev_button = de_prev_button,
        de_next_button = de_next_button
      )
    )

  })
}
