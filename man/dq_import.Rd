\name{dq_import}
\alias{dq_import}
\title{Import data quality resolutions}
\usage{
dq_import(client, data)
}
\arguments{
\item{client}{A \code{dq_client} object.}
\item{data}{Export-shaped data as a JSON string or R list.}
}
\value{Parsed API response for the import request.}
\description{Calls the external module import endpoint using \code{page=import}.}
\examples{
\dontrun{
cli <- dq_client("https://redcap.example.org/api/", Sys.getenv("REDCAP_TOKEN"), 123)
exported <- dq_export(cli, raw = TRUE)
dq_import(cli, exported)
}
}
