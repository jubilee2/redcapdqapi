\name{dq_flatten}
\alias{dq_flatten}
\title{Flatten exported data quality payload}
\usage{
dq_flatten(x)
}
\arguments{
\item{x}{A \code{dq_export} object or a parsed export list.}
}
\value{A list with \code{status} and \code{resolutions} data frames.}
\description{Pure transformation helper for \code{dq_export()} payloads.}
\examples{
fixture <- jsonlite::read_json(
  system.file("extdata", "example_export.json", package = "redcapdqapi"),
  simplifyVector = FALSE
)
out <- dq_flatten(fixture)
names(out)
}
