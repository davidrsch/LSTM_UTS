box::use(
  dplyr[across, bind_cols, contains, lead, left_join, matches, mutate, n],
  dplyr[pull, rename, select, slice],
  keras3[
    compile,
    fit,
    keras_input,
    keras_model,
    layer_dense,
    layer_lstm,
    layer_reshape
  ],
  purrr[map, reduce],
  stats[na.omit, predict],
  tibble[as_tibble, tibble],
  tidyr[nest],
)

# Getting 3d vectors
#' @export
multiple_lead <- function(data, n) {
  data |>
    mutate(across(
      matches(names(data)),
      \(x) lead(x, n = n),
      .names = "lead_{col}_n{n}"
    )) |>
    mutate(index = dplyr::row_number(), .before = value) |>
    select(-value)
}

# - Inputs. Gets the data, the amount of historical data to use,
# temporal horizon and returns a 3d vector (samples, historical data, 1)
#' @export
get_input_vector <- function(data, inp_amount, horizon) {
  names(data) <- "value"
  if (inp_amount == 1) {
    inputs <- data[1:(dim(data)[1] - horizon), ]
  } else {
    n <- 0:(inp_amount - 1)
    data <- data |>
      slice(1:(n() - horizon))
    inputs <- n |>
      map(\(x) multiple_lead(data = data, n = x)) |>
      reduce(left_join, "index") |>
      select(-index) |>
      na.omit()
  }
  # inputs
  inputs |>
    as.matrix() |>
    array(c(dim(inputs), 1))
}

# - Outputs. Gets the data, the amount of historical data to use,
# temporal horizon and returns a 3d vector (samples, temporal horizon, 1)
#' @export
get_output_vector <- function(data, inp_amount, horizon) {
  names(data) <- "value"
  if (horizon == 1) {
    outputs <- data[(inp_amount + 1):dim(data)[1], ]
  } else {
    n <- 0:(horizon - 1)
    data <- data |>
      slice((inp_amount + 1):n())
    outputs <- n |>
      map(\(x) multiple_lead(data = data, n = x)) |>
      reduce(left_join, "index") |>
      select(-index) |>
      na.omit()
  }
  # outputs
  outputs |>
    as.matrix() |>
    array(c(dim(outputs), 1))
}

# Getting model. Receive the historical data, the temporal horizon and
# the amount of neurons for the LSTM and returns a simple model
#' @export
get_model <- function(inp_amount, horizon, lstm) {
  input <- keras_input(shape = c(inp_amount, 1))
  hidden <- input |>
    layer_lstm(units = lstm)
  output <- hidden |>
    layer_dense(units = horizon) |>
    layer_reshape(c(horizon, 1))
  model <- keras_model(inputs = input, outputs = output)
  model |>
    compile(loss = "mse", optimizer = "adam")
  # model
  model
}

# Fit the model in each time step by the specified epoch amount and
# store predictions for each subsequent step.
# - Create an empty 3d array to store predictions.
# - Iterate along the samples to train and obtain predictions.
#' @export
fit_predict <- function(model, input_vec, output_vec, epoch) {
  predictions <- rep(NA, ((dim(output_vec)[1] - 1) * dim(output_vec)[2])) |>
    matrix(ncol = dim(output_vec)[2]) |>
    array(c((dim(output_vec)[1] - 1), dim(output_vec)[2], dim(output_vec)[3]))

  for (i in seq_len(dim(input_vec)[1])) {
    model |>
      fit(
        input_vec[i, , , drop = FALSE],
        output_vec[i, , , drop = FALSE],
        epochs = epoch,
        verbose = 0
      )
    if (i != dim(input_vec)[1]) {
      predictions[i, , ] <- model |>
        predict(input_vec[(i + 1), , , drop = FALSE])
    }
  }
  predictions
}

# Get two d predictions
#' @export
slide_columns <- function(data, column) {
  c(
    rep(NA, column - 1),
    pull(data, column),
    rep(NA, dim(data)[2] - column)
  )
}

# Extract predictions as a tibble,
# - If temporal horizon is 1 stay as it is
# - Else find mean value of each time point along the predictions
#' @export
twod_predictions <- function(predictions_3d) {
  predictions <- predictions_3d[, , 1] |>
    as_tibble(.name_repair = "unique")

  if (dim(predictions)[2] == 1) {
    names(predictions) <- "prediction"
  } else {
    n <- seq_len(dim(predictions)[2])
    predictions <- n |>
      map(\(x) slide_columns(data = predictions, x)) |>
      bind_cols() |>
      rowMeans(na.rm = TRUE) |>
      tibble() |>
      rename(prediction = contains("rowMeans"))
  }
  predictions
}

# Aggregate the process of previous functions. Receiving a one column
# tibble with the data and another containing the necessary info to
# create, fit and obtain predictions with a model
#' @export
model_flow <- function(data, modeldata) {
  inp_amount <- modeldata$inp_amount
  horizon <- modeldata$horizon
  lstm <- modeldata$lstm
  epoch <- modeldata$epoch
  inputs <- get_input_vector(data, inp_amount, horizon)
  outputs <- get_output_vector(data, inp_amount, horizon)
  model <- get_model(inp_amount, horizon, lstm)
  predictions <- fit_predict(model, inputs, outputs, epoch)
  # predictions
  twod_predictions(predictions)
}

# Test the process of creating and obtaining predictions by the number
# defined in tests specified in the model data
# - Extract the amount of test
# - Creates an empty tibble to store each test in a column
# - Iterate to create the tests
# Returns a one cell tibble with tibble test nested
#' @export
test_model_flow <- function(data, modeldata) {
  tests <- modeldata$tests
  inp_amount <- modeldata$inp_amount
  horizon <- modeldata$horizon
  modeldata <- modeldata |> select(-tests)

  amount_pred <- length((inp_amount + 2):dim(data)[1])
  pred_tests <- rep(NA, (amount_pred * tests)) |>
    matrix(ncol = tests) |>
    as_tibble(.name_repair = "unique")
  names(pred_tests) <- gsub(pattern = "...", "test_", names(pred_tests))

  for (i in 1:tests) {
    pred_tests[, i] <- model_flow(data, modeldata)
  }

  # pred_tests
  pred_tests |>
    nest() |>
    rename(tests = data)
}
