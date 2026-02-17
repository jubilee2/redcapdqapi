#' Create a REDCap Data Quality API client
#'
#' @param api_url REDCap API endpoint URL, typically ending in `/api/`.
#' @param token A REDCap API token for the target project.
#' @param pid REDCap project ID.
#'
#' @return An object of class `dq_client`.
#' @examples
#' cli <- dq_client(
#'   api_url = "https://redcap.example.org/api/",
#'   token = "REDACTED",
#'   pid = 123
#' )
#' @export
dq_client <- function(api_url, token, pid) {
  validate_scalar_string(api_url, "api_url")
  validate_scalar_string(token, "token")

  if (!(is.numeric(pid) || is.character(pid)) || length(pid) != 1 || is.na(pid)) {
    stop("`pid` must be a single numeric value or numeric string.", call. = FALSE)
  }

  structure(
    list(
      api_url = api_url,
      token = token,
      pid = as.character(pid)
    ),
    class = "dq_client"
  )
}
