test_that("build_import_payload converts minimal rows into import payload", {
  x <- data.frame(
    record = c("1001", "1002"),
    event_id = c("1", "1"),
    field_name = c("age", "height"),
    comment = c("verify age", "verify height"),
    username = c("qa_user", "qa_user2"),
    assigned_username = c("qa_user", "qa_user2"),
    stringsAsFactors = FALSE
  )

  payload <- redcapdqapi:::build_import_payload(x, project_id = "194")

  expect_type(payload, "list")
  expect_equal(length(payload), 2)

  first <- payload[[1]]
  expect_equal(first$project_id, "194")
  expect_equal(first$record, "1001")
  expect_equal(first$status_id, "")
  expect_equal(first$assigned_username, "qa_user")
  expect_equal(first$resolutions[[1]]$status_id, "")
  expect_equal(first$resolutions[[1]]$comment, "verify age")
  expect_equal(first$resolutions[[1]]$response_requested, "1")
  expect_equal(first$resolutions[[1]]$current_query_status, "OPEN")
  expect_match(first$resolutions[[1]]$ts, "^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}$")
})

test_that("build_import_payload supports optional assignment columns and status_id", {
  x <- data.frame(
    record = "1001",
    event_id = "",
    field_name = "age",
    comment = "needs source check",
    username = "qa_user",
    assigned_username = "qa_user",
    response_requested = "1",
    status_id = "42",
    stringsAsFactors = FALSE
  )

  payload <- redcapdqapi:::build_import_payload(x, project_id = "194")
  row <- payload[[1]]

  expect_equal(row$assigned_username, "qa_user")
  expect_equal(row$resolutions[[1]]$username, "qa_user")
  expect_equal(row$resolutions[[1]]$response_requested, "1")
  expect_equal(row$status_id, "42")
  expect_equal(row$resolutions[[1]]$status_id, "42")
})

test_that("build_import_payload accepts username without assigned_username", {
  x <- data.frame(
    record = "1001",
    event_id = "",
    field_name = "age",
    comment = "needs source check",
    username = "qa_user",
    stringsAsFactors = FALSE
  )

  payload <- redcapdqapi:::build_import_payload(x, project_id = "194")
  row <- payload[[1]]

  expect_null(row$assigned_username)
  expect_equal(row$resolutions[[1]]$username, "qa_user")
})


test_that("build_import_payload defaults event_id to empty string when omitted", {
  x <- data.frame(
    record = "1001",
    field_name = "age",
    comment = "needs source check",
    username = "qa_user",
    stringsAsFactors = FALSE
  )

  payload <- redcapdqapi:::build_import_payload(x, project_id = "194")

  expect_equal(payload[[1]]$event_id, "")
})

test_that("build_import_payload supports optional current_query_status values", {
  allowed <- c("OPEN", "CLOSED", "VERIFIED", "DEVERIFIED")

  for (status in allowed) {
    x <- data.frame(
      record = "1001",
      field_name = "age",
      comment = "needs source check",
      username = "qa_user",
      current_query_status = status,
      stringsAsFactors = FALSE
    )

    payload <- redcapdqapi:::build_import_payload(x, project_id = "194")
    expect_equal(payload[[1]]$resolutions[[1]]$current_query_status, status)
  }
})

test_that("build_import_payload defaults blank current_query_status to OPEN", {
  x <- data.frame(
    record = "1001",
    field_name = "age",
    comment = "needs source check",
    username = "qa_user",
    current_query_status = "",
    stringsAsFactors = FALSE
  )

  payload <- redcapdqapi:::build_import_payload(x, project_id = "194")
  expect_equal(payload[[1]]$resolutions[[1]]$current_query_status, "OPEN")
})

test_that("build_import_payload normalizes current_query_status casing and whitespace", {
  x <- data.frame(
    record = "1001",
    field_name = "age",
    comment = "needs source check",
    username = "qa_user",
    current_query_status = "  verified  ",
    stringsAsFactors = FALSE
  )

  payload <- redcapdqapi:::build_import_payload(x, project_id = "194")
  expect_equal(payload[[1]]$resolutions[[1]]$current_query_status, "VERIFIED")
})


test_that("build_import_payload rejects invalid current_query_status values", {
  x <- data.frame(
    record = "1001",
    field_name = "age",
    comment = "needs source check",
    username = "qa_user",
    current_query_status = "IN_REVIEW",
    stringsAsFactors = FALSE
  )

  expect_error(
    redcapdqapi:::build_import_payload(x, project_id = "194"),
    "`data\\$current_query_status` must be one of"
  )
})


test_that("dq_import rejects malformed minimal data frame before network call", {
  cli <- dq_client("https://redcap.example.org/api/", token = "abc", pid = 12)

  bad <- data.frame(
    record = "1001",
    event_id = "",
    field_name = "age",
    assigned_username = "qa_user",
    stringsAsFactors = FALSE
  )

  expect_error(
    dq_import(cli, bad),
    "`data` data frame is missing required columns: comment, username."
  )
})

test_that("dq_import rejects minimal data frame without username", {
  cli <- dq_client("https://redcap.example.org/api/", token = "abc", pid = 12)

  bad <- data.frame(
    record = "1001",
    event_id = "",
    field_name = "age",
    comment = "please verify",
    assigned_username = "qa_user",
    stringsAsFactors = FALSE
  )

  expect_error(
    dq_import(cli, bad),
    "`data` data frame is missing required columns: username."
  )
})
