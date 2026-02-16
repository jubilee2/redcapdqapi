#' Export data quality status/resolution information
#'
#' Wraps the external module's `export` endpoint.
#'
#' @param client A `dq_client`.
#' @param records Optional character vector of record IDs to filter to.
#' @param user Optional username to filter to the assigned user.
#' @param status Optional query status filter (e.g., "OPEN", "CLOSED", "VERIFIED", "DEVERIFIED").
#' @param raw If TRUE, return the nested list exactly as parsed from JSON.
#'
#' @return If `raw=TRUE`, a nested list keyed by `status_id`. Otherwise a list with
#'   `status` and `resolutions` tibbles (see `dq_flatten()`).
#' @export
dq_export <- function(client, records = NULL, user = NULL, status = NULL, raw = FALSE) {
  if (!inherits(client, "dq_client")) rlang::abort("`client` must be a dq_client.")
  body <- list(
    token = client$token,
    format = "json",
    returnFormat = "json"
  )

  # The upstream PHP uses $post['record'] (singular), but README examples often say "records".
  # Send both to be tolerant of upstream parsing.
  if (!is.null(records)) {
    body$record <- records
    body$records <- records
  }
  if (!is.null(user)) body$user <- user
  if (!is.null(status)) body$status <- status

  req <- dq_build_request(client, page = "export") |>
    httr2::req_body_form(!!!body)

  resp <- dq_perform(req)
  x <- httr2::resp_body_json(resp, simplifyVector = FALSE)

  if (isTRUE(raw)) return(x)
  dq_flatten(x)
}
