box::use(
  dplyr[across, all_of, arrange, bind_cols, bind_rows, distinct, if_else, left_join],
  dplyr[mutate, rename, row_number, select, slice, slice_tail, starts_with, summarize_all],
  purrr[map],
  stats[na.omit],
  stringr[str_detect],
  tibble[tibble],
  tidyr[nest, unnest],
)

box::use(
  app/logic/model[test_model_flow],
  app/logic/scale[get_actual_scales, get_all_scales],
  app/logic/transform[get_actual_serie, get_all_transformations],
)

# Get data to work with by using the specified sequence and forecast
# parameters.
# - If sequence is defined returns a tibble arranged by sequence.
# - Else return a tibble only with variable forecast
# In the resulted tibble variable will be renamed to "sequence" and
# "value"
#' @export
get_process_data <- function(data, sequence, forecast) {

  if (!any(is.null(sequence), sequence == "")) {
    new_data <- data[, c(sequence, forecast)]
    names(new_data) <- c("sequence", "value")
    new_data <- new_data |>
      arrange(sequence)
  } else {
    new_data <- data[, forecast]
    names(new_data) <- "value"
  }

  new_data <- na.omit(new_data)
  return(new_data)
}

# Function to returns min and max value of a column if column exist
# in data otherwise returns null
#' @export
extract_mi_ma <- function(data, variable) {
  names_data <- names(data)
  if (is.element(variable, names_data)) {
    min_max <- c(min(data[variable]), max(data[variable]))
  } else {
    min_max <- NULL
  }
  return(min_max)
}

# Function to obtain all the specified series to train on as base
# data to build the models.
# - Extract a tibble with transformation and the differentiations
# applied to obtain the transformations.
# - Extract the min and max values of the transformations to be
# able to revert scale in obtained predictions
# - Scale all the data
# Returns a list with data (a tibble of the resulting series after
# applying the desired transformations and rescales), the
# differentiations applied to obtain the transformations, and the
# original scales of the transformations.
#' @export
get_all_series <- function(data, transformations, scales) {
  data <- get_all_transformations(data, transformations)
  first_diff <- data$first_diff
  second_diff <- data$second_diff
  data <- data$data

  ex_min_max <- extract_mi_ma(data, "value")
  fi_min_max <- extract_mi_ma(data, "first")
  se_min_max <- extract_mi_ma(data, "second")

  data <- get_all_scales(data, scales)
  data <- list(
    data = data,
    first_diff = first_diff,
    second_diff = second_diff,
    ex_min_max = ex_min_max,
    fi_min_max = fi_min_max,
    se_min_max = se_min_max
  )
  return(data)
}

# Obtain all the tests for all the model configuration (modeldata) for
# the given variable (name) in data.
# - Creates an empty tibble to store in each row the nested results of
# the model flow test.
# - Iterate along all the models configuration
# - Join the tests along with the model configuration
# Returns a one row two columns tibble with the variable name an the
# model configuration tests nested.
#' @export
get_predict <- function(name, data, modeldata) {
  predictions <- tibble(tests_results = rep(NA, dim(modeldata)[1]))

  for (i in seq_len(dim(modeldata)[1])) {
    predictions[i, ] <- test_model_flow(data |> select(all_of(name)), modeldata[i, ])
  }

  predictions <- predictions |>
    mutate(index = row_number()) |>
    select(index, tests_results)
  modeldata <- modeldata |>
    mutate(index = row_number())
  predictions <- left_join(modeldata, predictions, by = "index") |>
    select(-index) |>
    nest() |>
    rename(model_data = data) |>
    mutate(data = name) |>
    select(data, model_data)
  return(predictions)
}

# Function to compute squared error
#' @export
squared_error <- function(x, y) {
  z <- (y - x)^2
  return(z)
}

# Function to get RMSE from test results and give proper format for
# analysis. Gets as input the data with test results transformed back
# to original and original data set.
# - Creates the empty RMSE to store values.
# - For each combination of series and model data:
# * Extract test results
# * Extract the original data corresponding to the predictions in tests
# results
# * Compute and store RMSE
# * Store along with tests results the corresponding original data
# - Combine the resulting RMSE tibble with data and extract and store
# transformations and scales in corresponding format to be use by analysis
# tool.
#' @export
get_results <- function(data, original) {
  data <- data |>
    unnest(model_data)
  rmse <- tibble(rmse = rep(NA, dim(data)[1]))

  for (i in seq_len(dim(data)[1])) {
    tests_results <- data |>
      slice(i) |>
      select(tests_results) |>
      unnest(tests_results)

    length_test_results <- dim(tests_results)[1]
    pred_original <- original |>
      select(value) |>
      slice_tail(n = length_test_results)

    rmse[i, ] <- bind_cols(tests_results, pred_original) |>
      mutate(across(starts_with("test_"), \(x) squared_error(x, value))) |>
      select(- value) |>
      summarize_all(mean) |>
      mutate(across(starts_with("test_"), \(x) sqrt(x))) |>
      rowMeans()

    if (is.element("sequence", names(original))) {
      tests_results <- tests_results |>
        bind_cols(
          original |>
            slice_tail(n = length_test_results)
        )
    } else {
      tests_results <- tests_results |>
        bind_cols(
          original |>
            slice_tail(n = length_test_results) |>
            mutate(sequence = seq_len(length_test_results), .before = value)
        )
    }

    tests_results <- tests_results |>
      nest() |>
      rename(tests_results = data)
    data[i, "tests_results"] <- tests_results
  }

  data <- bind_cols(data, rmse) |>
    mutate(
      transformations = str_detect(data, "value") |>
        if_else("Original", if_else(str_detect(data, "first"), "First", "Second")),
      scales = str_detect(data, "z_o") |>
        if_else("0 to 1", if_else(str_detect(data, "m_p"), "-1 to 1", "Exact")),
      .after = data
    ) |>
    select(-c(data, tests))
  return(data)
}

# Execute the process using the previously defined functions. Receive as
# input the data, the sequence and forecast variable, and the corresponding
# information for tests configuration.
# - Extract the corresponding sequence and forecast variable from data.
# - Apply transformations and scales data according to specified.
# - Store the necessary values to restore predictions to original values
# - Obtain predictions. Ensuring executing all model flow.
# - Store predictions back to original data scale and form.
# - Evaluate predictions and prepare for data analysis tool.
# Return results in a format appropriate to evaluate using analysis tool.
#' @export
process <- function(data, sequence, forecast, iterations) {
  data <- get_process_data(data, sequence, forecast)

  transformations <- unique(iterations$transformations)
  scales <- unique(iterations$scales)
  new_data <- get_all_series(data, transformations, scales)

  first_diff <- new_data$first_diff
  second_diff <- new_data$second_diff
  ex_min_max <- new_data$ex_min_max
  fi_min_max <- new_data$fi_min_max
  se_min_max <- new_data$se_min_max
  new_data <- new_data$data
  iterations <- iterations |>
    select(-c(transformations, scales)) |>
    distinct()

  names_nd <- names(new_data)
  predictions <- names_nd |>
    map(\(x) get_predict(name = x, new_data, iterations)) |>
    bind_rows()

  predictions <- get_actual_scales(predictions, ex_min_max, fi_min_max, se_min_max)
  predictions <- get_actual_serie(predictions, data, first_diff, second_diff)
  predictions <- get_results(predictions, data)
  return(predictions)
}
