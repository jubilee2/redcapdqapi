extract_query_param <- function(req, key) {
  list_sources <- list(req$query, req$params, req$args)
  for (source in list_sources) {
    if (is.list(source) && !is.null(source[[key]])) {
      return(as.character(source[[key]])[[1]])
    }
  }

  query_string <- NULL
  if (!is.null(req$query_string) && is.character(req$query_string) && length(req$query_string) > 0) {
    query_string <- req$query_string[[1]]
  }
  if (is.null(query_string) && !is.null(req$QUERY_STRING) && is.character(req$QUERY_STRING) && length(req$QUERY_STRING) > 0) {
    query_string <- req$QUERY_STRING[[1]]
  }

  url_candidates <- c(
    if (is.character(req$url) && length(req$url) > 0) req$url[[1]] else NULL,
    if (is.character(req$path) && length(req$path) > 0) req$path[[1]] else NULL,
    if (is.character(req$request_uri) && length(req$request_uri) > 0) req$request_uri[[1]] else NULL,
    if (is.character(req$REQUEST_URI) && length(req$REQUEST_URI) > 0) req$REQUEST_URI[[1]] else NULL
  )

  if (is.null(query_string)) {
    for (value in url_candidates) {
      if (is.character(value) && length(value) == 1 && nzchar(value) && grepl("?", value, fixed = TRUE)) {
        query_string <- sub("^[^?]*\\?", "", value)
        break
      }
    }
  }

  if (is.null(query_string) || !nzchar(query_string)) {
    return(NULL)
  }

  parts <- strsplit(query_string, "&", fixed = TRUE)[[1]]
  prefix <- paste0(key, "=")
  hit <- parts[startsWith(parts, prefix)]

  if (length(hit) == 0) {
    return(NULL)
  }

  utils::URLdecode(sub(prefix, "", hit[[1]], fixed = TRUE))
}

extract_form_data <- function(req, key = "data") {
  data_value <- req$params[[key]]

  if (is.null(data_value) && !is.null(req$body) && is.list(req$body)) {
    data_value <- req$body[[key]]
  }

  if (is.null(data_value) && !is.null(req$post) && is.list(req$post)) {
    data_value <- req$post[[key]]
  }

  raw_body <- NULL
  if (is.null(data_value) && !is.null(req$body)) {
    if (is.character(req$body) && length(req$body) == 1) {
      raw_body <- req$body
    } else if (is.raw(req$body)) {
      raw_body <- rawToChar(req$body)
    }
  }

  if (is.null(data_value) && !is.null(raw_body) && nzchar(raw_body)) {
    parts <- strsplit(raw_body, "&", fixed = TRUE)[[1]]
    prefix <- paste0(key, "=")
    hit <- parts[startsWith(parts, prefix)]

    if (length(hit) > 0) {
      data_value <- utils::URLdecode(sub(prefix, "", hit[[1]], fixed = TRUE))
    }
  }

  data_value
}

test_that("perform_request errors do not leak response body", {
  skip_if_not_installed("webfakes")

  app <- webfakes::new_app()
  app$post("/api/", function(req, res) {
    res$set_status(400)
    res$send("SECRET-PHI-CONTENT")
  })

  server <- webfakes::new_app_process(app)
  start_err <- tryCatch(
    {
      server$start()
      NULL
    },
    error = function(e) e
  )
  if (!is.null(start_err)) {
    skip(paste("webfakes app process is unavailable:", conditionMessage(start_err)))
  }
  on.exit(server$stop(), add = TRUE)

  cli <- dq_client(server$url("/api/"), token = "abc", pid = 12)

  err <- tryCatch(
    {
      dq_export(cli)
      NULL
    },
    error = function(e) e
  )

  expect_s3_class(err, "error")
  expect_true(grepl("HTTP 400", conditionMessage(err), fixed = TRUE))
  expect_false(grepl("SECRET-PHI-CONTENT", conditionMessage(err), fixed = TRUE))
})


test_that("dq_export validates status filter values", {
  cli <- dq_client("https://redcap.example.org/api/", token = "abc", pid = 12)

  expect_error(
    dq_export(cli, status = "IN_PROGRESS"),
    "`status` must be NULL or one of: OPEN, CLOSED, VERIFIED, DEVERIFIED."
  )
})

test_that("dq_client supports default and custom module prefix", {
  cli_default <- dq_client("https://redcap.example.org/api/", token = "abc", pid = 12)
  expect_identical(cli_default$prefix, "vanderbilt_dataQuality")

  cli_custom <- dq_client(
    "https://redcap.example.org/api/",
    token = "abc",
    pid = 12,
    prefix = "custom_prefix"
  )
  expect_identical(cli_custom$prefix, "custom_prefix")
})
