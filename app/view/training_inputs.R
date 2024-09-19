box::use(
  shiny.fluent[Dropdown.shinyInput, SpinButton.shinyInput, Stack],
  shiny.fluent[Text, TextField.shinyInput, updateTextField.shinyInput],
  shiny[moduleServer, NS, observeEvent, reactive, reactiveVal],
)

box::use(
  app/logic/constants[scales, transformations],
  app/logic/make_card[make_card],
  app/logic/max_min_width_input[max_min_width_input],
)

# Defining module UI inputs:
# - Time series
# * Transformation select, multiple choice (original, first, second)
# * Scales select, multiple choice (exact, 0 to 1, -1 to 1)
# - Training vectors
# * Temporal horizon (numeric input only one)
# * Historical amount (numeric input, more than one)
# - LSTM (numeric input, more than one)
# - Training and Testing
# * Epoch * Tests
#' @export
ui <- function(id) {
  ns <- NS(id)

  make_card(
    "",
    Stack(
      tokens = list(childrenGap = 10),
      Text(
        variant = "xLarge",
        "Transformations",
        block = TRUE
      ),
      Stack(
        horizontal = TRUE,
        tokens = list(childrenGap = "10%"),
        Dropdown.shinyInput(
          inputId = ns("transformation"),
          label = "Transformation",
          options = transformations,
          multiSelect = TRUE,
          styles = max_min_width_input(45),
          required = TRUE
        ),
        Dropdown.shinyInput(
          inputId = ns("scale"),
          label = "Scale",
          options = scales,
          multiSelect = TRUE,
          styles = max_min_width_input(45),
          required = TRUE
        )
      ),
      Text(
        variant = "xLarge",
        "Training vectors",
        block = TRUE
      ),
      Stack(
        horizontal = TRUE,
        tokens = list(childrenGap = "10%"),
        SpinButton.shinyInput(
          inputId = ns("horizon"),
          label = "Temporal horizon:",
          labelPosition = "top",
          styles = max_min_width_input(45),
          min = 1,
          value = 1,
          required = TRUE
        ),
        TextField.shinyInput(
          inputId = ns("inp_amount"),
          label = "Input amounts:",
          description = 'Separete amounts using commas: ","',
          required = TRUE
        )
      ),
      Text(
        variant = "xLarge",
        "LSTM",
        block = TRUE
      ),
      TextField.shinyInput(
        inputId = ns("lstm"),
        label = "Neurons:",
        description = 'Separete amounts using commas: ","',
        required = TRUE
      ),
      Text(
        variant = "xLarge",
        "Training & Testing",
        block = TRUE
      ),
      Stack(
        horizontal = TRUE,
        tokens = list(childrenGap = "10%"),
        SpinButton.shinyInput(
          inputId = ns("epoch"),
          label = "Epochs:",
          labelPosition = "top",
          styles = max_min_width_input(45),
          min = 1,
          value = 1
        ),
        SpinButton.shinyInput(
          inputId = ns("tests"),
          label = "Tests:",
          labelPosition = "top",
          styles = max_min_width_input(45),
          min = 1,
          value = 1
        )
      )
    ),
    style = "max-height: 550px; background-color: white;",
    is_contained = TRUE
  )
}

# Defining server side of module. This server take an additional
# parameter the status of the run button in page buttons.
# - Define a reactive value and observer to validate that input
# value is numeric
# - Define a reactive value and observer to validate that LSTM
# value is numeric
# - Define observe event to show or hide run button
# Return as reactive value the value of the inputs
#' @export
server <- function(id, run_button_status) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Defining a reactive value and observer to validate that input
    # value is numeric
    inp_amount_valid <- reactiveVal("")
    observeEvent(input$inp_amount, {
      inp_amount_valid <- gsub("[^0-9,]+", "", input$inp_amount)
      if (inp_amount_valid != input$inp_amount) {
        updateTextField.shinyInput(inputId = "inp_amount", value = inp_amount_valid)
      }
    })

    # Defining a reactive value and observer to validate that LSTM
    # value is numeric
    lstm_valid <- reactiveVal("")
    observeEvent(input$lstm, {
      lstm_valid <- gsub("[^0-9,]+", "", input$lstm)
      if (lstm_valid != input$lstm) {
        updateTextField.shinyInput(inputId = "lstm", value = lstm_valid)
      }
    })

    # Defining observe event to show or hide run button
    observeEvent(c(input$transformation, input$scale, input$inp_amount, input$lstm), {
      if (!any(is.null(input$transformation), input$transformation == "") &
            !any(is.null(input$scale), input$scale == "") &
            !any(is.null(input$inp_amount), grepl("[A-Za-z]|^$", input$inp_amount)) &
            !any(is.null(input$lstm), grepl("[A-Za-z]|^$", input$lstm))) {
        run_button_status("show")
      } else {
        run_button_status("hide")
      }
    })

    reactive(
      list(
        transformations = input$transformation,
        scales = input$scale,
        horizon = input$horizon,
        inp_amount = input$inp_amount,
        lstm = input$lstm,
        epoch = input$epoch,
        tests = input$tests
      )
    )

  })
}
