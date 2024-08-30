box::use(
  tibble[tribble]
)

status_mapping <- tribble(
  ~type, ~color, ~icon,
  "error", "red", "Error",
  "info", "blue", "Info",
  "succes", "green", "CheckMark",
  "warning", "yellow", "Warning"
)
