#' Export data quality statuses and resolutions
#'
#' Calls the external module export endpoint using `page=export`.
#'
#' @param client A `dq_client` object.
#' @param records Optional character vector of record IDs.
#' @param user Optional scalar username filter.
#' @param status Optional scalar query status filter: `OPEN`, `CLOSED`, `VERIFIED`, or `DEVERIFIED`.
#' @param raw If `TRUE`, return raw JSON text.
#'
#' @return If `raw = TRUE`, a JSON string. Otherwise a structured object of class
#'   `dq_export` containing the raw JSON and parsed content.
#' @examples
#' \dontrun{
#' cli <- dq_client("https://redcap.example.org/api/", Sys.getenv("REDCAP_TOKEN"), 123)
#' payload <- dq_export(cli)
#' json_text <- dq_export(cli, raw = TRUE)
#' }
#' @export
dq_export <- function(client, records = NULL, user = NULL, status = NULL, raw = FALSE) {
  if (!inherits(client, "dq_client")) {
    stop("`client` must be a dq_client object.", call. = FALSE)
  }

  if (!is.null(records) && (!is.character(records) || any(is.na(records)))) {
    stop("`records` must be NULL or a character vector with no NA values.", call. = FALSE)
  }

  if (!is.null(user)) {
    validate_scalar_string(user, "user")
  }

  if (!is.null(status)) {
    validate_export_status(status)
  }

  validate_scalar_logical(raw, "raw")

  body <- list(token = client$token, format = "json", returnFormat = "json")
  if (!is.null(records)) {
    body$record <- records
  }
  if (!is.null(user)) body$user <- user
  if (!is.null(status)) body$status <- status

  endpoint <- paste0(client$api_url, "?page=export&type=module&prefix=", client$prefix)
  req <- do.call(httr2::req_body_form, c(list(new_module_request(client, "export")), body))

  text <- perform_request(req, endpoint) |>
    httr2::resp_body_string()

  if (isTRUE(raw)) {
    return(text)
  }

  parse_export_text(text)
}
