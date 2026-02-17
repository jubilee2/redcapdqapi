#' Validate that an object is a scalar string
#'
#' @param x The object to validate.
#' @param name The name of the object to use in the error message.
#'
#' @return Invisible `NULL`, but throws an error if validation fails.
#' @noRd
validate_scalar_string <- function(x, name) {
  if (!is.character(x) || length(x) != 1 || is.na(x) || !nzchar(x)) {
    stop(sprintf("`%s` must be a single non-empty string.", name), call. = FALSE)
  }
}
