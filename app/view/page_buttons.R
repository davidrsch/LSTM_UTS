box::use(
  shiny.fluent[DefaultButton.shinyInput, PrimaryButton.shinyInput],
  shiny.fluent[Stack, updateDefaultButton.shinyInput],
  shiny[NS, moduleServer, observeEvent, reactive, reactiveVal],
  shinyjs[hidden, hide, show, toggleClass],
)

# This module defines the buttons to pass from importing file
# to configure run and also execute the experiment.
#' @export
ui <- function(id) {
  ns <- NS(id)

  # Defining previous and next buttons
  Stack(
    horizontal = TRUE,
    horizontalAlign = "center",
    tokens = list(childrenGap = "15px"),
    hidden(
      DefaultButton.shinyInput(
        ns("prevtbutton"),
        text = "Previous",
        disabled = TRUE,
        `data-testid` = "prevtbutton",
      )
    ),
    hidden(
      PrimaryButton.shinyInput(
        ns("runbutton"),
        text = "Run",
        `data-testid` = "runbutton",
      )
    ),
    hidden(
      DefaultButton.shinyInput(
        ns("nextbutton"),
        text = "Next",
        disabled = FALSE,
        `data-testid` = "nextbutton",
      )
    )
  )
}

# The server module takes as additional parameter run_modal_state,
# a reactive value from to modify the visibility of run_modal modal.
# - Define reactive value with observer to show and hide previous and
# next buttons.
# - Define reactive value with observer to show and hide run button
# - Define reactive value to disable or enable previous button
# - Define reactive value to disable or enable next button
# - Define event in previous button to enable disable page buttons
# and turning panel by toggling class "turnpanel"
# - Define event in next button to enable disable page buttons
# and turning panel by toggling class "turnpanel"
# - Define event in run button to affect visibility of run_modal
# This server output a list of the 4 reactive values that allows
# other modules to enable/disable or modify visibility of buttons.
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

    # - Defining event in previous button to enable disable page buttons
    # and turning panel by toggling class "turnpanel"
    observeEvent(input$prevtbutton, {
      de_next_button("enable")
      de_prev_button("disable")
      toggleClass(
        selector = ".panelcontainer",
        class = "turnpanel"
      )
    })

    # - Defining event in next button to enable disable page buttons
    # and turning panel by toggling class "turnpanel"
    observeEvent(input$nextbutton, {
      de_next_button("disable")
      de_prev_button("enable")
      toggleClass(
        selector = ".panelcontainer",
        class = "turnpanel"
      )
    })

    # Defining event in run button to affect visibility of run_modal
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
