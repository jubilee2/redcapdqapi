# redcapdqapi

Lightweight R client for the Vanderbilt REDCap Group **data_quality_api** external module.

## What this wraps

This package calls the external module endpoints:

- `...?prefix=<prefix>&page=export&pid=<pid>&type=module&NOAUTH`
- `...?prefix=<prefix>&page=import&pid=<pid>&type=module&NOAUTH`

and posts a body similar to the standard REDCap API (`token`, `format`, etc.).

## Quick start

```r
library(redcapdqapi)

cli <- dq_client(
  api_url = "https://redcap.vumc.org/api/",
  token   = Sys.getenv("REDCAP_TOKEN"),
  pid     = 12345,
  prefix  = "data_quality_api"
)

out <- dq_export(cli, records = c("1001", "1002"), status = "OPEN")
out$status
out$resolutions

# Re-import the same structure (API will skip duplicates)
res_ids <- dq_import(cli, dq_export(cli, raw = TRUE))
```

## Notes

1) The external module must be enabled in the REDCap Control Center and on the project.  
2) Import inserts **new** resolutions only; it does not overwrite old ones.
