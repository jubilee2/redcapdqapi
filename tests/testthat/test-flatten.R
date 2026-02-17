test_that("dq_flatten handles parsed fixture", {
  fixture_path <- test_path("fixtures", "example_export.json")
  x <- redcapdqapi::dq_read_json(fixture_path)
  out <- redcapdqapi::dq_flatten(x)

  expect_true(is.list(out))
  expect_named(out, c("status", "resolutions"))
  expect_s3_class(out$status, "tbl_df")
  expect_s3_class(out$resolutions, "tbl_df")

  expect_named(
    out$status,
    c(
      "status_id", "rule_id", "pd_rule_id", "non_rule", "project_id", "record",
      "event_id", "field_name", "repeat_instrument", "instance", "status", "exclude",
      "query_status", "assigned_username"
    )
  )

  expect_named(
    out$resolutions,
    c(
      "res_id", "status_id", "ts", "response_requested", "response", "comment",
      "current_query_status", "upload_doc_id", "field_comment_edited", "username"
    )
  )
})

test_that("dq_flatten handles dq_export objects", {
  fixture_path <- test_path("fixtures", "example_export.json")
  raw <- paste(readLines(fixture_path, warn = FALSE), collapse = "\n")
  out <- redcapdqapi::dq_flatten(
    structure(
      list(raw = raw, data = jsonlite::fromJSON(raw, simplifyVector = FALSE)),
      class = "dq_export"
    )
  )

  expect_equal(nrow(out$status), 1)
  expect_equal(nrow(out$resolutions), 1)
})
