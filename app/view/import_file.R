box::use(
  shiny.fluent[
    Checkbox.shinyInput, Stack, TextField.shinyInput,
    updateCheckbox.shinyInput, updateTextField.shinyInput],
  shiny[fileInput, moduleServer, NS, observeEvent, reactive],
  stringr[str_split_i],
)

box::use(
  app/logic/constants[file_formats],
  app/logic/make_card[make_card],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  make_card(
    "Import file",
    Stack(
      tokens = list(childrenGap = 10),
      fileInput(
        ns("file"),
        "Upload a file"),
      Checkbox.shinyInput(
        ns("header"),
        label = "Has header?",
        value = TRUE,
        disabled = TRUE),
      Stack(
        horizontal = TRUE,
        tokens = list(childrenGap = 10),
        TextField.shinyInput(
          ns("delimiter"),
          label = "Delimiter",
          value = ",",
          disabled = TRUE),
        TextField.shinyInput(
          ns("decimal_point"),
          label = "Decimal point",
          value = ".",
          disabled = TRUE)
      )
    ),
    style = "max-height: 320px;",
    is_contained = TRUE
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Enabling or disabling inputs depending on the imported file format
    observeEvent(input$file, {
      if (!is.null(input$file)) {
        file_path <- input$file$datapath
        format <- str_split_i(file_path, "\\.", -1)
        if (is.element(format, file_formats[["extention"]])) {
          updateCheckbox.shinyInput(
            inputId = "header",
            disabled = FALSE)
          if (is.element(format, file_formats[file_formats$type == "text", ][["extention"]])) {
            updateTextField.shinyInput(
              inputId = "delimiter",
              disabled = FALSE
            )
            updateTextField.shinyInput(
              inputId = "decimal_point",
              disabled = FALSE
            )
          } else {
            updateTextField.shinyInput(
              inputId = "delimiter",
              disabled = TRUE
            )
            updateTextField.shinyInput(
              inputId = "decimal_point",
              disabled = TRUE
            )
          }

        } else {
          updateCheckbox.shinyInput(
            inputId = "header",
            disabled = TRUE)
          updateTextField.shinyInput(
            inputId = "delimiter",
            disabled = TRUE
          )
          updateTextField.shinyInput(
            inputId = "decimal_point",
            disabled = TRUE
          )
        }
      }
    })

    reactive(
      list(
        file = input$file,
        header = input$header,
        delimiter = input$delimiter,
        decimal_point = input$decimal_point)
    )

  })
}
