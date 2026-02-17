new_module_request <- function(client, page) {
  httr2::request(client$api_url) |>
    httr2::req_method("POST") |>
    httr2::req_timeout(60) |>
    httr2::req_url_query(
      prefix = "data_quality_api",
      type = "module",
      page = page,
      NOAUTH = "",
      pid = client$pid
    ) |>
    httr2::req_error(is_error = function(resp) FALSE)
}

perform_request <- function(req, endpoint) {
  response <- httr2::req_perform(req)
  status <- httr2::resp_status(response)

  if (status >= 400) {
    stop(
      sprintf(
        "Request to %s failed with HTTP %s.",
        endpoint,
        status
      ),
      call. = FALSE
    )
  }

  response
}

parse_export_text <- function(text) {
  parsed <- jsonlite::fromJSON(text, simplifyVector = FALSE)
  structure(
    list(raw = text, data = parsed),
    class = "dq_export"
  )
}

parse_import_text <- function(text) {
  jsonlite::fromJSON(text, simplifyVector = TRUE)
}

as_json_payload <- function(data) {
  if (is.character(data) && length(data) == 1 && !is.na(data)) {
    return(data)
  }

  jsonlite::toJSON(data, auto_unbox = TRUE, null = "null")
}

#' Write export-shaped data to JSON
#'
#' @param x Export-shaped data list.
#' @param path Destination file path.
#'
#' @return The `path`, invisibly.
#' @export
dq_write_json <- function(x, path) {
  jsonlite::write_json(x, path, auto_unbox = TRUE, pretty = TRUE, null = "null")
  invisible(path)
}

#' Read export-shaped data from JSON
#'
#' @param path Source file path.
#'
#' @return Parsed list with `simplifyVector = FALSE`.
#' @export
dq_read_json <- function(path) {
  jsonlite::read_json(path, simplifyVector = FALSE)
}
