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
