box::use(
  tibble[tribble],
)

file_formats <- tribble(
  ~type, ~extention,
  "text", "csv",
  "text", "tsv",
  "excel", "xlsx",
  "excel", "xls")
status_mapping <- tribble(
  ~type, ~color, ~icon,
  "error", "red", "Error",
  "info", "blue", "Info",
  "succes", "green", "CheckMark",
  "warning", "yellow", "Warning"
)
transformations <- list(
  list(key = "original", text = "Original"),
  list(key = "first", text = "First"),
  list(key = "second", text = "Second")
)
scales <- list(
  list(key = "exact", text = "Exact"),
  list(key = "zero_one", text = "0 to 1"),
  list(key = "minus_plus", text = "-1 to 1")
)
