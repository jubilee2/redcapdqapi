\name{dq_import}
\alias{dq_import}
\title{Import data quality query comments}
\usage{
dq_import(client, data)
}
\arguments{
\item{client}{A \code{dq_client} object.}
\item{data}{Import payload as one of:
\itemize{
\item raw JSON string
\item export-shaped R list
\item minimal data frame with columns \code{record}, \code{field_name}, \code{comment}
plus required \code{username} (\code{event_id} defaults to \code{""} if omitted;
optional \code{assigned_username}; optional \code{response_requested} (defaults to \code{"1"}); optional \code{response}
in \code{DATA_MISSING}, \code{TYPOGRAPHICAL_ERROR}, \code{CONFIRMED_CORRECT}, \code{WRONG_SOURCE}, \code{OTHER}, or blank;
optional \code{current_query_status} in \code{OPEN}, \code{CLOSED}, \code{VERIFIED}, \code{DEVERIFIED}, or blank (default is \code{OPEN})
(one query resolution payload row is created per row)
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
  field_name = "age",
  comment = "Please verify this value",
  username = "data.team",
  stringsAsFactors = FALSE
)
dq_import(cli, minimal)
}
}
