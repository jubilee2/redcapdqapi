#' Write export structure to JSON
#' @param x Nested list from `dq_export(raw=TRUE)` (or similar).
#' @param path Output file path.
#' @export
dq_write_json <- function(x, path) {
  jsonlite::write_json(x, path, auto_unbox = TRUE, pretty = TRUE, null = "null")
  invisible(path)
}

#' Read export structure from JSON
#' @param path Path to a JSON file produced by `dq_write_json()`.
#' @export
dq_read_json <- function(path) {
  jsonlite::read_json(path, simplifyVector = FALSE)
}
