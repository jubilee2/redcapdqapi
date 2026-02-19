## Build goal
Create an R package from scratch that wraps the Vanderbilt REDCap [data_quality_api](https://github.com/vanderbilt-redcap/data_quality_api) external module.

## Core dependencies
- httr2
- jsonlite
- (Optional but OK) tibble for tidy outputs; otherwise return base data.frames

## Public API (stable)
- dq_client(api_url, token, pid, prefix = "vanderbilt_dataQuality")
- dq_export(client, records = NULL, user = NULL, status = NULL, raw = FALSE)
- dq_import(client, data)
- dq_flatten(x)

## Behavior requirements
- dq_export:
  - Calls REDCap API endpoint with module params:
    - prefix=<prefix>, type=module, page=export, NOAUTH
  - Supports filters: records (character vector), user (scalar), status (scalar)
  - If raw=TRUE return raw JSON text; otherwise return a structured object of class `dq_export`
- dq_import:
  - Calls page=import, posting data=<json> where JSON matches export output
  - Accept `data` as raw JSON string OR R list (convert to JSON)
- dq_flatten:
  - Pure function (no I/O). Takes a `dq_export` object or parsed list
  - Returns list(status=<data.frame/tibble>, resolutions=<data.frame/tibble>) with stable column names

## Clean code constraints
- Separate I/O from parsing/transformations (request_* vs parse_* vs flatten)
- Validate inputs early (api_url, pid, token, records type)
- Consistent error handling with informative messages:
  - include endpoint + HTTP status + safe snippet of response
  - NEVER print/log token
- No global state; client is explicit

## Testing
- Use testthat.
- Add unit tests with testthat for all public functions.
- Prefer fixtures: include at least one export JSON fixture and test dq_flatten + parsing.
- Mock HTTP in unit tests when possible; no live server dependency required.

## Documentation
- roxygen2 docs for all exported functions with examples.
- README with minimal end-to-end usage (Sys.getenv("REDCAP_TOKEN")) and security note.

## CI
- GitHub Actions: R-CMD-check on macOS/windows/ubuntu.

## Additional repo conventions
- Keep exported functions minimal and stable; place internals in non-exported helpers.
- Prefer small pure helpers for transformations to maximize testability.
- Return predictable schemas from flattening helpers; avoid dynamic column names.
- Keep examples non-networked and safe for CRAN-style checks.

## Contribution workflow
- Run unit tests locally before opening PR using `Rscript -e 'testthat::test_dir("tests/testthat", load_package = "source")'` when possible.
- Keep commits scoped and descriptive.
- Update documentation and tests in the same change when behavior changes.
