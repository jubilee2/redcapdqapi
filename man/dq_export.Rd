\name{dq_export}
\alias{dq_export}
\title{Export data quality statuses and resolutions}
\usage{
dq_export(client, records = NULL, user = NULL, status = NULL, raw = FALSE)
}
\arguments{
\item{client}{A \code{dq_client} object.}
\item{records}{Optional character vector of record IDs.}
\item{user}{Optional scalar username filter.}
\item{status}{Optional scalar query status filter: \code{OPEN}, \code{CLOSED}, \code{VERIFIED}, or \code{DEVERIFIED}.}
\item{raw}{If \code{TRUE}, return raw JSON text.}
}
\value{If \code{raw = TRUE}, a JSON string; otherwise a structured object of class
\code{dq_export} containing raw JSON and parsed content.}
\description{Calls the external module export endpoint using \code{page=export}.}
\examples{
\dontrun{
cli <- dq_client("https://redcap.example.org/api/", Sys.getenv("REDCAP_TOKEN"), 123)
payload <- dq_export(cli)
json_text <- dq_export(cli, raw = TRUE)
}
}
