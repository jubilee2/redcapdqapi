## Project mission
Maintain and evolve this R package that wraps the Vanderbilt REDCap [data_quality_api](https://github.com/vanderbilt-redcap/data_quality_api) external module.

## Core dependencies
- Required: `httr2`, `jsonlite`, `tibble`
- Testing/docs toolchain: `testthat`, `webfakes`, `knitr`, `rmarkdown`

## Stable public API (do not break without explicit versioned change)
- `dq_client(api_url, token, pid, prefix = "vanderbilt_dataQuality")`
- `dq_export(client, records = NULL, user = NULL, status = NULL, raw = FALSE)`
- `dq_import(client, data)`
- `dq_flatten(x)`

## Behavioral contracts
- `dq_export()`
  - Calls REDCap API module endpoint with query params: `prefix=<prefix>`, `type=module`, `page=export`, `NOAUTH`
  - Supports filters: `records` (character vector), `user` (scalar), `status` (scalar)
  - `raw = TRUE` returns raw JSON text; otherwise returns class `dq_export`
- `dq_import()`
  - Calls `page=import` and posts `data=<json>`
  - Accepts input as:
    - raw JSON string, or
    - R list (converted to JSON), or
    - minimal data.frame payload (validated and normalized by package helpers)
- `dq_flatten()`
  - Pure transformation (no I/O)
  - Accepts a `dq_export` object or parsed list
  - Returns `list(status=<tabular>, resolutions=<tabular>)` with stable column schemas

## Code quality constraints
- Keep I/O and transformations separated (`request_*` / `parse_*` / `flatten_*` style boundaries)
- Validate inputs early (`api_url`, `pid`, `token`, filters/payload types)
- Use consistent, informative HTTP errors including endpoint, status, and safe response snippet
- Never print, log, or include tokens in errors
- No global state; always pass explicit client objects

## Testing requirements
- Use `testthat`; maintain coverage for all public functions
- Prefer fixture-based tests (include export fixture coverage for parsing + flattening)
- Mock HTTP (no live REDCap dependency in unit tests)
- Run locally before PR when possible:
  - `Rscript -e 'testthat::test_dir("tests/testthat", load_package = "source")'`

## Documentation requirements
- roxygen2 docs for all exported functions with safe, non-networked examples
- README must include:
  - minimal end-to-end usage via `Sys.getenv("REDCAP_TOKEN")`
  - token security note
  - practical import expectations and known limitations

## CI policy
- Keep GitHub Actions `R-CMD-check` green for all configured OS targets in workflow.
- If matrix targets change, update this AGENTS.md and workflow together.

## Known upstream/module limitations (do not misclassify as package bugs)
- Import path creates new comments/replies; existing comments are not editable via this API path
- Repeat instrument behavior for new query insertion is constrained by upstream external module behavior

## Contribution workflow
- Keep commits scoped and descriptive
- Update tests and docs in the same change when behavior changes
- Preserve stable output schemas from flattening helpers (avoid dynamic column names)
