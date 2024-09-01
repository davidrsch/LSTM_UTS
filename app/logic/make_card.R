box::use(
  glue[glue],
  htmltools[div],
  shiny.fluent[Stack, Text],
)

#' @export
make_card <- function(title, content, size = 12, style = "", is_contained = FALSE) {
  if (is_contained) {
    card_class <- "card ms-depth-8"
  } else {
    card_class <- glue("card ms-depth-8 ms-sm{size} ms-xl{size}")
  }
  div(
    class = card_class,
    style = style,
    Stack(
      tokens = list(childrenGap = 10),
      Text(variant = "xLarge", title, block = TRUE),
      content
    )
  )
}
