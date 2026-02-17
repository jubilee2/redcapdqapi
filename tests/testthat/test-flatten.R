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
      "query_status", "group_id", "assigned_username"
    )
  )

  expect_named(
    out$resolutions,
    c(
      "res_id", "status_id", "ts", "response_requested", "response", "comment",
      "current_query_status", "upload_doc_id", "field_comment_edited",
      "migration_status", "migration_doc_id", "username"
    )
  )
})

test_that("dq_flatten includes group and migration columns for API-shaped payload", {
  payload <- list(
    "2801447" = list(
      status_id = "2801447",
      rule_id = NULL,
      pd_rule_id = NULL,
      non_rule = "1",
      project_id = "194",
      record = "122",
      event_id = "5194",
      field_name = "daily_m2",
      repeat_instrument = NULL,
      instance = "1",
      status = NULL,
      exclude = "0",
      query_status = "OPEN",
      group_id = "1550",
      assigned_username = "foo@example.com",
      resolutions = list(
        "2920750" = list(
          res_id = "2920750",
          status_id = "2801447",
          ts = "2025-09-14 13:11:01",
          response_requested = "1",
          response = NULL,
          comment = "test",
          current_query_status = "OPEN",
          upload_doc_id = NULL,
          field_comment_edited = "0",
          migration_status = NULL,
          migration_doc_id = NULL,
          username = "foo@example.com"
        )
      )
    )
  )

  out <- redcapdqapi::dq_flatten(payload)

  expect_equal(out$status$group_id[[1]], "158550")
  expect_true(is.na(out$resolutions$migration_status[[1]]))
  expect_true(is.na(out$resolutions$migration_doc_id[[1]]))
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
