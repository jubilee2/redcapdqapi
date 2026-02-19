new_module_request <- function(client, page) {
  httr2::request(client$api_url) |>
    httr2::req_method("POST") |>
    httr2::req_timeout(60) |>
    httr2::req_url_query(
      prefix = client$prefix,
      type = "module",
      page = page,
      NOAUTH = "",
      pid = client$pid
    ) |>
    httr2::req_error(is_error = function(resp) FALSE)
}

safe_response_snippet <- function(response) {
  body <- tryCatch(
    httr2::resp_body_string(response),
    error = function(e) ""
  )

  trimmed <- trimws(body)
  if (!nzchar(trimmed)) {
    return("<empty>")
  }

  parsed <- tryCatch(
    jsonlite::fromJSON(trimmed, simplifyVector = FALSE),
    error = function(e) NULL
  )

  if (is.null(parsed)) {
    return("<non-json response omitted>")
  }

  if (is.list(parsed)) {
    keys <- names(parsed)
    if (length(keys) > 0) {
      return(sprintf("json_keys=[%s]", paste(keys, collapse = ",")))
    }
  }

  "<json response>"
}

perform_request <- function(req, endpoint) {
  response <- httr2::req_perform(req)
  status <- httr2::resp_status(response)

  if (status >= 400) {
    stop(
      sprintf(
        "Request to %s failed with HTTP %s. Response snippet: %s",
        endpoint,
        status,
        safe_response_snippet(response)
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
    if (!isTRUE(jsonlite::validate(data))) {
      stop("`data` JSON string is not valid JSON.", call. = FALSE)
    }

    return(data)
  }

  if (!is.list(data)) {
    stop("`data` must be a single JSON string or an R list.", call. = FALSE)
  }

  jsonlite::toJSON(data, auto_unbox = TRUE, null = "null")
}
