box::use(
  dplyr[distinct],
  purrr[map],
  stringr[str_split],
  tibble[as_tibble],
)

#' @export
determine_iterations <- function(transformations, scales,
                                 horizon, inp_amount, lstm, epoch, tests, ...) {
  inp_amount <- str_split(inp_amount, ",")[[1]]
  lstm <- str_split(lstm, ",")[[1]]
  parameters <- c(as.list(environment()), list(...))
  max_options <- max(unlist(map(parameters, length))
  )
  iterations <- parameters |>
    map(rep, length.out = max_options) |>
    as_tibble() |>
    expand.grid() |>
    distinct()
  return(iterations)
}
