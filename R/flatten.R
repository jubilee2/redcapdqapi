#' Flatten data quality export output
#'
#' Turns the nested export structure (status rows with nested resolutions) into
#' two tidy tibbles.
#'
#' @param x Nested list as returned by `dq_export(raw = TRUE)`.
#'
#' @return A list with `status` and `resolutions` tibbles.
#' @export
dq_flatten <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return(list(
      status = tibble::tibble(),
      resolutions = tibble::tibble()
    ))
  }
  # x is keyed by status_id; each element contains status fields + optionally $resolutions
  status_rows <- lapply(names(x), function(k) {
    row <- x[[k]]
    res <- row$resolutions
    row$resolutions <- NULL
    row$status_id_key <- k
    row
  })
  status_df <- dplyr::bind_rows(lapply(status_rows, tibble::as_tibble))

  res_rows <- lapply(names(x), function(k) {
    row <- x[[k]]
    if (is.null(row$resolutions) || length(row$resolutions) == 0) return(NULL)
    res <- row$resolutions
    # res may be a named list keyed by res_id
    out <- lapply(names(res), function(rid) {
      rr <- res[[rid]]
      rr$res_id_key <- rid
      rr$status_id_parent <- k
      rr
    })
    dplyr::bind_rows(lapply(out, tibble::as_tibble))
  })
  res_rows <- Filter(Negate(is.null), res_rows)
  res_df <- if (length(res_rows)) dplyr::bind_rows(res_rows) else tibble::tibble()

  list(status = status_df, resolutions = res_df)
}
