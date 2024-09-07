box::use(
  shiny.fluent[DefaultButton.shinyInput, PrimaryButton.shinyInput, reactOutput, renderReact, Stack, updateDefaultButton.shinyInput],
  shiny[moduleServer, NS, observeEvent, reactive, reactiveVal],
  shinyjs[hidden, hide, show, toggleClass],
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
  Stack(
    horizontal = TRUE,
    horizontalAlign = 'center',
    tokens = list(
      childrenGap = "15px"),
    hidden(DefaultButton.shinyInput(
      ns("prevtbutton"),
      text = "Previous",
      disabled = TRUE
    )),
    hidden(PrimaryButton.shinyInput(
      ns("runbutton"),
      text = "Run"
    )),
    hidden(DefaultButton.shinyInput(
      ns("nextbutton"),
      text = "Next",
      disabled = FALSE
    ))
  )
}

#' @export
server <- function(id, run_modal_state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Defining reactive value hidden or showing page buttons
    hs_page_buttons <- reactiveVal("hide")
    observeEvent(hs_page_buttons(), {
      if (hs_page_buttons() == "hide") {
        hide("prevtbutton")
        hide("nextbutton")
        hide("runbutton")
      } else {
        show("prevtbutton")
        show("nextbutton")
      }
    })

    # Defining reactive value hidden or showing run button
    hs_run_button <- reactiveVal("hide")
    observeEvent(hs_run_button(), {
      if (hs_run_button() == "hide") {
        hide("runbutton")
      } else {
        show("runbutton")
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
      toggleClass(
        selector = ".panelcontainer",
        class = "turnpanel")
    })

    observeEvent(input$nextbutton, {
      de_next_button("disable")
      de_prev_button("enable")
      toggleClass(
        selector = ".panelcontainer",
        class = "turnpanel")
    })

    observeEvent(input$runbutton, {
      run_modal_state(TRUE)
    })

    reactive(
      list(
        hs_page_buttons = hs_page_buttons,
        hs_run_button = hs_run_button,
        de_prev_button = de_prev_button,
        de_next_button = de_next_button
      )
    )

  })
}
