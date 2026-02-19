# redcapdqapi

`redcapdqapi` is a lightweight R wrapper for the Vanderbilt REDCap
`data_quality_api` external module.

## Install

```r
# install from GitHub
remotes::install_github("jubilee2/redcapdqapi")

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

# Convenience path: minimal data frame -> OPEN status + one resolution comment
minimal <- data.frame(
  record = "1001",
  event_id = "1",
  field_name = "age",
  comment = "Please verify this value",
  assigned_username = "data.team",
  stringsAsFactors = FALSE
)
dq_import(client, minimal)
```

## Security note

- Store tokens in environment variables such as `REDCAP_TOKEN`.
- Never hardcode tokens in scripts, notebooks, or source control.
- This package avoids including tokens in error messages.

## Known limitations

- **Repeat instrument support (upstream limitation)**
  The REDCap Data Quality External Module (`import.php`) currently does not
  persist `repeat_instrument` when inserting a new status row. Because of this,
  `dq_import()` cannot create a status scoped to a specific repeating
  instrument instance. This behavior is an upstream module limitation, not an
  issue in this R client.

- **Import creates new resolutions only**
  Import supports creating new resolution comments only; existing resolutions
  cannot be modified through this API.

- **Duplicate resolution detection key**
  Duplicate resolution detection is based on `(status_id, ts, user_id)`.
  Resolutions with the same timestamp and user are treated as duplicates and
  skipped.

## API surface

- `dq_client(api_url, token, pid, prefix = "vanderbilt_dataQuality")`
- `dq_export(client, records = NULL, user = NULL, status = NULL, raw = FALSE)`
- `dq_import(client, data)`
- `dq_flatten(x)`
