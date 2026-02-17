# redcapdqapi

`redcapdqapi` is a lightweight R wrapper for the Vanderbilt REDCap
`data_quality_api` external module.

## Install

```r
# local development
# remotes::install_local(".")
```

## Minimal usage

```r
library(redcapdqapi)

client <- dq_client(
  api_url = "https://redcap.example.org/api/",
  token = Sys.getenv("REDCAP_TOKEN"),
  pid = 12345
)

# Export as structured dq_export object
exported <- dq_export(client)

# Flatten to two tabular outputs
flat <- dq_flatten(exported)
flat$status
flat$resolutions

# Re-import either raw JSON text or list
raw_json <- dq_export(client, raw = TRUE)
dq_import(client, raw_json)
```

## Security note

- Store tokens in environment variables such as `REDCAP_TOKEN`.
- Never hardcode tokens in scripts, notebooks, or source control.
- This package avoids including tokens in error messages.

## API surface

- `dq_client(api_url, token, pid, prefix = "data_quality_api")`
- `dq_export(client, records = NULL, user = NULL, status = NULL, raw = FALSE)`
- `dq_import(client, data)`
- `dq_flatten(x)`
