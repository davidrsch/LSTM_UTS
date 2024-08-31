box::use(
  shiny.fluent[Modal, Stack, Text, FontIcon, IconButton.shinyInput, reactOutput,
    renderReact],
  htmltools[div],
  shiny[moduleServer, NS, observeEvent],
  ../logic/constants[status_mapping],
)
# Defining making_modla module
#' @export
ui <- function(id) {
  ns <- NS(id)

  reactOutput(ns("make_modal"))
}

#' @export
server <- function(id, is_open, title, content, status, status_table = status_mapping) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    icon_name <- status_table[status_table$type == status, "icon"][[1]]
    icon_color <- status_table[status_table$type == status, "color"][[1]]
    div_icon_style <- paste0(
      "display: flex; flex-wrap: nowrap; justify-content: center; align-items: center; color: ",
      icon_color,";"
    )
    observeEvent(input$hideModal, is_open(FALSE))
    
    output$make_modal <- renderReact({
      Modal(isOpen = is_open(),
          Stack(tokens = list(padding = "15px", childrenGap = "10px"),
            div(style = list(display = "flex"),
              div(
                FontIcon(
                  iconName = icon_name),
                style = div_icon_style),
              Text(title, variant = "large"),
              div(style = list(flexGrow = 1)),
              IconButton.shinyInput(
                ns("hideModal"),
                iconProps = list(iconName = "Cancel")
              ),
            ),
            content
          )
        )
    })
  })
}

