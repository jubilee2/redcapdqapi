test_that("dq_client rejects api_url without protocol", {
  expect_error(
    redcapdqapi::dq_client("redcap.example.org/api/", token = "abc", pid = 12),
    "`api_url` must start with http:// or https://.",
    fixed = TRUE
  )
})

test_that("dq_client rejects empty api_url", {
  expect_error(
    redcapdqapi::dq_client("", token = "abc", pid = 12),
    "`api_url` must be a single non-empty string.",
    fixed = TRUE
  )
})

test_that("dq_client rejects empty token", {
  expect_error(
    redcapdqapi::dq_client("https://redcap.example.org/api/", token = "", pid = 12),
    "`token` must be a single non-empty string.",
    fixed = TRUE
  )
})

test_that("dq_client rejects invalid pid values", {
  expect_error(
    redcapdqapi::dq_client("https://redcap.example.org/api/", token = "abc", pid = NA),
    "`pid` must be a single numeric value or numeric string.",
    fixed = TRUE
  )

  expect_error(
    redcapdqapi::dq_client("https://redcap.example.org/api/", token = "abc", pid = c(12, 13)),
    "`pid` must be a single numeric value or numeric string.",
    fixed = TRUE
  )

  expect_error(
    redcapdqapi::dq_client("https://redcap.example.org/api/", token = "abc", pid = TRUE),
    "`pid` must be a single numeric value or numeric string.",
    fixed = TRUE
  )
})

test_that("dq_client accepts character numeric pid", {
  cli <- redcapdqapi::dq_client(
    "https://redcap.example.org/api/",
    token = "abc",
    pid = "123"
  )

  expect_identical(cli$pid, "123")
})
