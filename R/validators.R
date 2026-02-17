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

#' Validate export status filter
#'
#' @param status Status value to validate.
#'
#' @return Invisible `NULL`, but throws an error if validation fails.
#' @noRd
validate_export_status <- function(status) {
  validate_scalar_string(status, "status")

  allowed <- c("OPEN", "CLOSED", "VERIFIED", "DEVERIFIED")
  if (!status %in% allowed) {
    stop(
      sprintf(
        "`status` must be NULL or one of: %s.",
        paste(allowed, collapse = ", ")
      ),
      call. = FALSE
    )
  }
}

#' Validate scalar logical values
#'
#' @param x The object to validate.
#' @param name The name of the object to use in the error message.
#'
#' @return Invisible `NULL`, but throws an error if validation fails.
#' @noRd
validate_scalar_logical <- function(x, name) {
  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    stop(sprintf("`%s` must be TRUE or FALSE.", name), call. = FALSE)
  }
}
