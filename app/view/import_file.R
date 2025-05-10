box::use(
  shiny.fluent[Checkbox.shinyInput, PrimaryButton.shinyInput, Stack],
  shiny.fluent[TextField.shinyInput],
  shiny.fluent[updateCheckbox.shinyInput, updateTextField.shinyInput],
  shiny[div, fileInput, moduleServer, NS, observeEvent, reactive],
  shiny[tagAppendAttributes],
  shinyjs[click, hidden],
  stringr[str_split_i],
)

box::use(
  app / logic / constants[file_formats],
  app / logic / make_card[make_card],
  app / logic / max_min_width_input[max_min_width_input],
)

# Import file module with inputs for:
# - upload file   - specify if data includes header row
# - delimiter     - decimal point
# The server outputs the value of the mentioned input inside a
# reactive list
#' @export
ui <- function(id) {
  ns <- NS(id)

  div(
    make_card(
      "Import file",
      Stack(
        tokens = list(childrenGap = 10),
        PrimaryButton.shinyInput(
          ns("file"),
          text = "Upload a file",
          iconProps = list(iconName = "Upload"),
          `data-testid` = "file"
        ),
        Checkbox.shinyInput(
          ns("header"),
          label = "Has header?",
          value = TRUE,
          disabled = TRUE,
          inputProps = list(
            `data-testid` = "header"
          )
        ),
        Stack(
          horizontal = TRUE,
          tokens = list(childrenGap = "10%"),
          TextField.shinyInput(
            ns("delimiter"),
            label = "Delimiter",
            value = ",",
            disabled = TRUE,
            styles = max_min_width_input(45),
            `data-testid` = "delimiter"
          ),
          TextField.shinyInput(
            ns("decimal_point"),
            label = "Decimal point",
            value = ".",
            disabled = TRUE,
            styles = max_min_width_input(45),
            `data-testid` = "decimal_point"
          )
        )
      ),
      style = "max-height: 320px; background-color: white;",
      is_contained = TRUE
    ),
    hidden(
      fileInput(ns("upload_file"), "") |>
        tagAppendAttributes(`data-testid` = "upload_file")
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(input$file, {
      click("upload_file")
    })

    # Enabling or disabling inputs depending on the imported file
    # format
    observeEvent(input$upload_file, {
      if (!is.null(input$upload_file)) {
        file_path <- input$upload_file$datapath
        format <- str_split_i(file_path, "\\.", -1)
        if (is.element(format, file_formats[["extensions"]])) {
          updateCheckbox.shinyInput(
            inputId = "header",
            disabled = FALSE
          )
          if (
            is.element(
              format,
              file_formats[file_formats$type == "text", ][["extensions"]]
            )
          ) {
            updateTextField.shinyInput(
              inputId = "delimiter",
              disabled = FALSE,
              required = TRUE
            )
            updateTextField.shinyInput(
              inputId = "decimal_point",
              disabled = FALSE,
              required = TRUE
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
            disabled = TRUE
          )
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
        file = input$upload_file,
        header = input$header,
        delimiter = input$delimiter,
        decimal_point = input$decimal_point
      )
    )
  })
}
