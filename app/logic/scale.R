box::use(
  dplyr[across, bind_cols, matches, mutate, pull, select, starts_with],
  purrr[map],
  scales[rescale],
  stringr[str_detect],
  tidyr[nest, unnest],
)

# Get scaled series
#' @export
zero_to_one <- function(x) {
  y <- rescale(x = x, to = c(0, 1), from = c(min(x), max(x)))
  return(y)
}

#' @export
minus_to_plus <- function(x) {
  y <- rescale(x = x, to = c(-1, 1), from = c(min(x), max(x)))
  return(y)
}

# Apply specified scales to data.
# - Checks and get the specified scales.
# Returns a tibble where each column represents a scaled data.
#' @export
get_all_scales <- function(data, scales) {
  exact <- NULL
  zero_one <- NULL
  minus_plus <- NULL
  match <- "value|first|second"
  if (is.element("exact", scales)) {
    exact <- data |>
      select(matches(match))
  }
  if (is.element("zero_one", scales)) {
    zero_one <- data |>
      mutate(across(matches(match), zero_to_one, .names = "z_o_{.col}")) |>
      select(starts_with("z_o_"))
  }
  if (is.element("minus_plus", scales)) {
    minus_plus <- data |>
      mutate(across(matches(match), minus_to_plus, .names = "m_p_{.col}")) |>
      select(starts_with("m_p_"))
  }
  scaled <- list(exact, zero_one, minus_plus)
  no_null <- !unlist(map(scaled, is.null))
  scaled <- scaled[no_null] |>
    bind_cols()
  return(scaled)
}

# Rescale tests results to original scale. Receive as input the output
# from model flow, the name of the series to scale back, the min and max of
# the different transformations.
# - Detect the scale of the specified series
# - Rescale back
# Returns back the data in the same format as in model flow but with tests
# results already scaled back.
#' @export
rescale_back <- function(data, serie, ex_min_max, fi_min_max, se_min_max) {
  if (str_detect(serie, "z_o")) {
    f_min_max <- c(0, 1)
  } else {
    f_min_max <- c(-1, 1)
  }

  if (str_detect(serie, "value")) {
    t_min_max <- ex_min_max
  } else if (str_detect(serie, "first")) {
    t_min_max <- fi_min_max
  } else {
    t_min_max <- se_min_max
  }

  data <- data |>
    filter(data == serie) |>
    unnest(model_data) |>
    unnest(tests_results) |>
    mutate(
      across(
        starts_with("test_"),
        \(x) rescale(x, from = f_min_max, to = t_min_max))) |>
    nest(tests_results = starts_with("test_")) |>
    nest(model_data = c(horizon, inp_amount, lstm, epoch, tests, tests_results))
  return(data)
}

# Execute the previous define function only on those tests results that need to
# be rescaled back.
#' @export
get_actual_scales <- function(data, ex_min_max, fi_min_max, se_min_max) {
  series <- data |>
    select(data) |>
    pull()
  for (i in seq_along(series)) {
    if (!is.element(series[i], c("value", "first", "second"))) {
      data[which(data[, 1] == series[i]), ] <- rescale_back(
        data, series[i], ex_min_max, fi_min_max, se_min_max)
    }
  }
  return(data)
}
