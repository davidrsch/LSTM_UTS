box::use(
  shiny.fluent[FontIcon, IconButton.shinyInput, Modal, reactOutput],
  shiny.fluent[Stack, Text, renderReact],
  shiny[NS, div, moduleServer, observeEvent],
)

box::use(
  app / logic / constants[status_mapping],
)

# Defining make_modal module
#' @export
ui <- function(id) {
  ns <- NS(id)

  reactOutput(ns("make_modal"))
}

# This module server receive as additional input:
# - is_open: Boolean to open or close the modal dynamically
# - title: to define title of the modal
# - content: to define the content of the modal
# - status & status_table: to define the status of the modal and get
# from status_table the corresponding features as type, color and icon
#' @export
server <- function(
  id,
  name,
  is_open,
  title,
  content,
  status,
  status_table = status_mapping
) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    icon_name <- status_table[status_table$type == status, "icon"][[1]]
    icon_color <- status_table[status_table$type == status, "color"][[1]]
    div_icon_style <- paste0(
      "display: flex; flex-wrap: nowrap; justify-content: center; align-items: center; color: ",
      icon_color,
      ";"
    )
    observeEvent(input$hideModal, is_open(FALSE))

    output$make_modal <- renderReact({
      Modal(
        isOpen = is_open(),
        Stack(
          tokens = list(padding = "15px", childrenGap = "10px"),
          div(
            style = list(display = "flex"),
            div(
              FontIcon(iconName = icon_name),
              style = div_icon_style
            ),
            Text(title, variant = "large"),
            div(style = list(flexGrow = 1)),
            IconButton.shinyInput(
              ns("hideModal"),
              iconProps = list(iconName = "Cancel"),
              `data-testid` = paste0("close_", name)
            ),
          ),
          content
        )
      )
    })
  })
}
