box::use(
  dplyr[all_of, mutate],
  tibble[tibble],
)

#' @export
get_options <- function(names, disabled_op = NULL) {
  options <- tibble(key = names, text = names)

  if (!is.null(disabled_op)) {
    if (disabled_op != "") {
      options <- options |>
        mutate(
          disabled = is.element(key, all_of(disabled_op))
        )
    }
  }

  options <- options |>
    split(seq_along(names)) |>
    unname() |>
    lapply(function(x) {
      as.list(x)
    })
}
