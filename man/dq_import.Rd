\name{dq_import}
\alias{dq_import}
\title{Import data quality resolutions}
\usage{
dq_import(client, data)
}
\arguments{
\item{client}{A \code{dq_client} object.}
\item{data}{Import payload as one of:
\itemize{
\item raw JSON string
\item export-shaped R list
\item minimal data frame with columns \code{record}, \code{event_id}, \code{field_name}, \code{comment}, \code{assigned_username}
(one OPEN status with one resolution comment is created per row)
}}
}
\value{Parsed API response for the import request.}
\description{Calls the external module import endpoint using \code{page=import}.}
\examples{
\dontrun{
cli <- dq_client("https://redcap.example.org/api/", Sys.getenv("REDCAP_TOKEN"), 123)
exported <- dq_export(cli, raw = TRUE)
dq_import(cli, exported)

minimal <- data.frame(
  record = "1001",
  event_id = "1",
  field_name = "age",
  comment = "Please verify this value",
  assigned_username = "data.team",
  stringsAsFactors = FALSE
)
dq_import(cli, minimal)
}
}
