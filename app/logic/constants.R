box::use(
  tibble[tribble]
)

file_formats <- c("csv","tsv","xlsx","xls")
status_mapping <- tribble(
  ~type, ~color, ~icon,
  "error", "red", "Error",
  "info", "blue", "Info",
  "succes", "green", "CheckMark",
  "warning", "yellow", "Warning"
)
