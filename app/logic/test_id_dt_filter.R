box::use(
  DT[JS],
)

# Define testid for data table header filters. This function takes as
# input the table name that should be pass to the testid
#' @export
test_id_dt_filter <- function(name) {
  jsfunction <- paste0(
    "function(settings, json) {",
    "$(this.api().table().header()).find('tr:eq(1) td').slice(1).each(function(index) {",
    "$(this).find('input[type=\"search\"]').attr('data-testid', '",
    name,
    "filter-' + (index + 1));",
    "});",
    "}"
  ) |>
    JS()
  return(jsfunction)
}
