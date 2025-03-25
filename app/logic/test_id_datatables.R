box::use(
  DT[JS],
)

# Define testid for data table header filters. This function takes as
# input the table name that should be pass to the testid
#' @export
test_id_datatables <- function(name) {
  # jsfunction
  paste0(
    "function(settings, json) {",
    # Add 'data-testid' to filters
    "$(this.api().table().header()).find('tr:eq(1) td').slice(1).each(function(index) {",
    "$(this).find('input[type=\"search\"]').attr('data-testid', '",
    name,
    "filter-' + (index + 1));",
    "});",

    # Add 'data-testid' to pagination buttons (Previous/Next)
    "$('.dataTables_paginate .paginate_button.previous').attr('data-testid', '",
    name,
    "-previous');",
    "$('.dataTables_paginate .paginate_button.next').attr('data-testid', '",
    name,
    "-next');",

    # Ensure 'data-testid' is maintained after each redraw (paging, etc.)
    "$(document).on('draw.dt', function() {",
    "$('.dataTables_paginate .paginate_button.previous').attr('data-testid', '",
    name,
    "-previous');",
    "$('.dataTables_paginate .paginate_button.next').attr('data-testid', '",
    name,
    "-next');",
    "});",
    "}"
  ) |>
    JS()
}
