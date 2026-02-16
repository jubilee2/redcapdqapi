test_that("dq_flatten produces two tibbles", {
  x <- dq_read_json(system.file("extdata", "example_export.json", package = "redcapdqapi"))
  out <- dq_flatten(x)
  expect_s3_class(out$status, "tbl_df")
  expect_s3_class(out$resolutions, "tbl_df")
  expect_true(nrow(out$status) >= 1)
  expect_true(nrow(out$resolutions) >= 1)
})
