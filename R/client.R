#' Create a Data Quality API client
#'
#' @param api_url REDCap API endpoint URL, typically ending in `/api/`.
#' @param token A REDCap API token for the target project.
#' @param pid REDCap project ID (numeric).
#' @param prefix External module prefix (from the Control Center / module configuration).
#' @param ssl_verify Whether to verify TLS certificates (default TRUE).
#' @param timeout_seconds Request timeout.
#'
#' @return An object of class `dq_client`.
#' @export
dq_client <- function(api_url, token, pid, prefix, ssl_verify = TRUE, timeout_seconds = 60) {
  if (!is.character(api_url) || length(api_url) != 1 || !nzchar(api_url)) rlang::abort("`api_url` must be a non-empty string.")
  if (!is.character(token) || length(token) != 1 || !nzchar(token)) rlang::abort("`token` must be a non-empty string.")
  if (!is.numeric(pid) && !is.character(pid)) rlang::abort("`pid` must be numeric or a numeric string.")
  pid <- as.character(pid)
  if (!is.character(prefix) || length(prefix) != 1 || !nzchar(prefix)) rlang::abort("`prefix` must be a non-empty string.")

  structure(
    list(
      api_url = api_url,
      token = token,
      pid = pid,
      prefix = prefix,
      ssl_verify = isTRUE(ssl_verify),
      timeout_seconds = as.numeric(timeout_seconds)
    ),
    class = "dq_client"
  )
}

dq_build_request <- function(client, page) {
  httr2::request(client$api_url) |>
    httr2::req_url_query(
      prefix = client$prefix,
      page   = page,
      pid    = client$pid,
      type   = "module",
      NOAUTH = ""
    ) |>
    httr2::req_method("POST") |>
    httr2::req_timeout(client$timeout_seconds) |>
    httr2::req_options(ssl_verifypeer = client$ssl_verify)
}

dq_perform <- function(req) {
  resp <- httr2::req_perform(req)
  if (httr2::resp_status(resp) >= 400) {
    body <- tryCatch(httr2::resp_body_string(resp), error = function(e) "")
    rlang::abort(paste0("Data Quality API request failed (HTTP ", httr2::resp_status(resp), "). ", body))
  }
  resp
}
