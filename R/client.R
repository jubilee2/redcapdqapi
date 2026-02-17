#' Create a REDCap Data Quality API client
#'
#' @param api_url REDCap API endpoint URL, typically ending in `/api/`.
#' @param token A REDCap API token for the target project.
#' @param pid REDCap project ID.
#' @param prefix External module prefix. Defaults to `"vanderbilt_dataQuality"`.
#'
#' @return An object of class `dq_client`.
#' @examples
#' cli <- dq_client(
#'   api_url = "https://redcap.example.org/api/",
#'   token = "REDACTED",
#'   pid = 123,
#'   prefix = "vanderbilt_dataQuality"
#' )
#' @export
dq_client <- function(api_url, token, pid, prefix = "vanderbilt_dataQuality") {
  validate_scalar_string(api_url, "api_url")
  validate_scalar_string(token, "token")

  if (!(is.numeric(pid) || is.character(pid)) || length(pid) != 1 || is.na(pid)) {
    stop("`pid` must be a single numeric value or numeric string.", call. = FALSE)
  }
  validate_scalar_string(prefix, "prefix")

  structure(
    list(
      api_url = api_url,
      token = token,
      pid = as.character(pid),
      prefix = prefix
    ),
    class = "dq_client"
  )
}
