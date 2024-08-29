box::use(
  shiny.fluent[Stack, Text],
  htmltools[div],
  glue[glue],
)

#' @export
make_card <- function(title, content, size = 12, style = "") {
  div(
    class = glue("card ms-depth-8 ms-sm{size} ms-xl{size}"),
    style = style,
    Stack(
      Text(variant = "large", title, block = TRUE),
      content
    )
  )
}