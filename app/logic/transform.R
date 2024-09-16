box::use(
  dplyr[across, filter, group_by, left_join, mutate, n, pull, rename],
  dplyr[row_number, select, slice, slice_head, slice_tail, starts_with, ungroup],
  fabletools[features],
  feasts[unitroot_ndiffs],
  purrr[map, reduce],
  stats[diffinv, na.omit],
  stringr[str_detect],
  tibble[tibble],
  tidyr[nest, unnest],
  tsibble[as_tsibble],
)

# Get necessary diff to make data stationary
#' @export
diff_test <- function(x) {
  unitroot_ndiffs(x, differences = 0:10)
}

#' @export
get_necessary_diff <- function(data) {
  diffs <- data |>
    mutate(sequence = as.Date(sequence)) |>
    as_tsibble(index = sequence) |>
    features(value, diff_test) |>
    select(ndiffs) |>
    pull()
  return(diffs)
}

# Get stationary data by applying difference if necessary:
# - If it is not necessary returns null
# - Else a list of the stationary data and the applied diff
#' @export
stationary_data <- function(data) {
  diffs <- get_necessary_diff(data)
  if (diffs == 0) {
    data <- NULL
  } else {
    sequence <- data |>
      select(sequence) |>
      slice((diffs + 1) : n()) |>
      pull()
    stationary <- data |>
      pull(value) |>
      diff(differences = diffs)
    data <- tibble(
      sequence = sequence,
      stationary = stationary
    )
    data <- list(data = data, diff = diffs)
  }
  return(data)
}

# Apply the first transformation
# - Rename the stationary value to identify the first transformation
#' @export
first_transformation <- function(data) {
  data <- stationary_data(data)
  if (!is.null(data)) {
    data$data <- data$data |>
      rename(first = stationary)
    names(data) <- c("data", "first_diff")
  }
  return(data)
}

# Apply the second transformation
# - If any value <=0 returns a list of data NULL and second_diff NULL.
#   Implying impossibility of second transformation.
# - Else find the logged value and check if it is necessary to differentiate to make stationary.
# * If already stationary return list of logged data and second_diff NULL.
# * Else returns list of stationary data and second_diff equal necessary diff
#' @export
second_transformation <- function(data) {
  if (any(data$value <= 0)) {
    data <- list(
      data = NULL,
      second_diff = NULL)
  } else {
    data <- data |>
      mutate(value = log(value))
    data_diff <- stationary_data(data)
    if (!is.null(data_diff)) {
      data_diff$data <- data_diff$data |>
        rename(second = stationary)
      names(data_diff) <- c("data", "second_diff")
      data <- data_diff
    } else {
      data <- list(
        data = data |>
          rename(second = value),
        second_diff = NULL)
    }
  }
  return(data)
}

# Apply specified transformations to a data.
# - If data have no sequence column it's created.
# - Checks and get the specified transformations.
# Returns a list with a tibble which columns correspond to the
# specified transformations (original, first, second) and the
# necessary diff for the transformations.
# Note: As transformation may include differentiation the number
# of observations in each transformation may vary. Therefore those
# case where a transformation had NA were eliminated, ensuring same
# number of observations in all transformation, which in turn ensure
# that all the models with equal characteristics are tested in the same
# amount of observations
#' @export
get_all_transformations <- function(data, transformations) {
  data_names <- names(data)
  if (!is.element("sequence", data_names)) {
    data <- data |>
      mutate(sequence = row_number())
  }
  original <- NULL
  first <- NULL
  second <- NULL
  first_diff <- NULL
  second_diff <- NULL
  if (is.element("original", transformations)) {
    original <- data
  }
  if (is.element("first", transformations)) {
    first <- first_transformation(data)
    first_diff <- first$first_diff
    first <- first$data
  }
  if (is.element("second", transformations)) {
    second <- second_transformation(data)
    second_diff <- second$second_diff
    second <- second$data
  }

  transformed <- list(original, first, second)
  no_null <- !unlist(map(transformed, is.null))
  transformed <- transformed[no_null] |>
    reduce(left_join, by = "sequence") |>
    na.omit()
  transformed <- list(
    data = transformed,
    first_diff = first_diff,
    second_diff = second_diff
  )
  return(transformed)
}

# Function to invert differentiations. Takes as input a numeric vector,
# a differentiation amount, the original data, and the input amount used
# to create 3d vectors for modeling.
# - Extract the necessary data from the original data taking into account
# the differentiation and inputs amount.
# - Invert the different of the numeric vector
# Returns a numeric vector without differentiation.
#' @export
invert_diff <- function(x, diff, original, inp_amount) {
  original <- original |>
    slice_head(n = diff + unique(inp_amount)) |>
    slice_tail(n = diff) |>
    select(value) |>
    pull()
  x <- diffinv(x, differences = diff, xi = original)
  x <- x[-seq_len(diff)]
  return(x)
}

# Run the previous function for each series ensuring the correct differentiation is use.
# - Determine the proper diff amount
# Returns the tests results obtained from model flow and scale back without
# differentiation.
#' @export
invert_diff_series <- function(data, serie, original, first_diff, second_diff) {
  if (str_detect(serie, "first")) {
    diff <- first_diff
  } else {
    diff <- second_diff
  }

  if (is.null(diff)) {
    data <- data |>
      filter(data == serie)
  } else {
    data <- data |>
      filter(data == serie) |>
      unnest(model_data) |>
      mutate(md = paste0(horizon, inp_amount, lstm, epoch, tests), .before = tests_results) |>
      group_by(md) |>
      unnest(tests_results) |>
      mutate(
        across(
          starts_with("test_"),
          \(x) invert_diff(x, diff, original, inp_amount))) |>
    nest(tests_results = starts_with("test_")) |>
    ungroup() |>
    select(-md) |>
    nest(model_data = c(horizon, inp_amount, lstm, epoch, tests, tests_results))
  }

  return(data)
}

# Run the previous function for each corresponding series.
# - Determine the series
# - Execute the previous function in the corresponding series.
# Returns the tests results obtained from model flow and scale back without
# differentiation.
#' @export
get_actual_serie <- function(data, original, first_diff, second_diff) {
  series <- data |>
    select(data) |>
    pull()

  for (i in seq_along(series)) {
    if (!str_detect(series[i], "value")) {
      data[which(data[, 1] == series[i]), ] <- invert_diff_series(
        data, series[i], original, first_diff, second_diff)
    }
  }
  return(data)
}
