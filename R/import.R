#' Import data quality query comments
#'
#' Calls the external module import endpoint using `page=import`.
#'
#' @param client A `dq_client` object.
#' @param data Import payload as one of:
#'   - raw JSON string
#'   - export-shaped R list. For each query row, use keys:
#'     - `status_id`, `record`, `event_id`, `field_name`, `assigned_username`
#'     - `repeat_instrument`, `instance`, `project_id`
#'     - `resolutions` (named list), where each resolution includes:
#'       - `res_id`, `status_id`, `ts`, `response_requested`, `response`
#'       - `comment`, `current_query_status`, `username`
#'   - minimal data frame with columns:
#'     - required: `record`, `field_name`, `comment`, `username`
#'     - optional: `event_id` (defaults to `""`), `assigned_username`, `repeat_instrument`, `instance`
#'     - optional: `response_requested` (defaults to `"1"`)
#'     - optional: `response` in `DATA_MISSING`, `TYPOGRAPHICAL_ERROR`,
#'       `CONFIRMED_CORRECT`, `WRONG_SOURCE`, `OTHER`, or blank
#'     - optional: `current_query_status` in `OPEN`, `CLOSED`, `VERIFIED`,
#'       `DEVERIFIED`, or blank (default is `OPEN`)
#'     - optional: `status_id`
#'     - one query resolution payload row is created per data-frame row
#'
#' @return Parsed API response for the import request.
#' @examples
#' \dontrun{
#' cli <- dq_client("https://redcap.example.org/api/", Sys.getenv("REDCAP_TOKEN"), 123)
#' exported <- dq_export(cli, raw = TRUE)
#' dq_import(cli, exported)
#'
#' minimal <- data.frame(
#'   record = "1001",
#'   field_name = "age",
#'   comment = "Please verify this value",
#'   username = "data.team",
#'   stringsAsFactors = FALSE
#' )
#' dq_import(cli, minimal)
#' }
#' @export
dq_import <- function(client, data) {
  if (!inherits(client, "dq_client")) {
    stop("`client` must be a dq_client object.", call. = FALSE)
  }

  if (is.data.frame(data)) {
    data <- build_import_payload(data, project_id = client$pid)
  }

  data_json <- as_json_payload(data)

  body <- list(
    token = client$token,
    format = "json",
    returnFormat = "json",
    data = data_json
  )

  endpoint <- paste0(client$api_url, "?page=import&type=module&prefix=", client$prefix)
  req <- do.call(httr2::req_body_form, c(list(new_module_request(client, "import")), body))

  text <- perform_request(req, endpoint) |>
    httr2::resp_body_string()

  parse_import_text(text)
}
