#' Import data quality resolutions
#'
#' Wraps the external module's `import` endpoint. The import only adds *new*
#' resolutions (duplicates based on timestamp + username are skipped upstream).
#'
#' @param client A `dq_client`.
#' @param data Either a nested list (export format) or a JSON string of that structure.
#'
#' @return Integer vector of inserted resolution IDs (as returned by the API).
#' @export
dq_import <- function(client, data) {
  if (!inherits(client, "dq_client")) rlang::abort("`client` must be a dq_client.")

  if (is.character(data) && length(data) == 1) {
    data_json <- data
  } else {
    data_json <- jsonlite::toJSON(data, auto_unbox = TRUE, null = "null")
  }

  body <- list(
    token = client$token,
    format = "json",
    returnFormat = "json",
    data = data_json
  )

  req <- dq_build_request(client, page = "import") |>
    httr2::req_body_form(!!!body)

  resp <- dq_perform(req)
  x <- httr2::resp_body_json(resp, simplifyVector = TRUE)
  x
}
