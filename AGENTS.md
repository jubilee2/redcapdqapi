## Build goal
Create an R package from scratch that wraps the Vanderbilt REDCap data_quality_api external module.

## Requirements
- Use httr2 + jsonlite
- Functions: dq_client(), dq_export(), dq_import(), dq_flatten()
- Export supports filters: record(s), user, status
- Import posts JSON payload from export
- Good errors, roxygen2 docs, examples, unit tests (fixtures), GitHub Actions R-CMD-check
- Never log or print the API token
