\name{dq_client}
\alias{dq_client}
\title{Create a REDCap Data Quality API client}
\usage{
dq_client(api_url, token, pid, prefix = "vanderbilt_dataQuality")
}
\arguments{
\item{api_url}{REDCap API endpoint URL, typically ending in \code{/api/}.}
\item{token}{A REDCap API token for the target project.}
\item{pid}{REDCap project ID.}
\item{prefix}{External module prefix. Defaults to \code{"vanderbilt_dataQuality"}.}
}
\value{An object of class \code{dq_client}.}
\description{Construct a client object used by \code{dq_export()} and \code{dq_import()}.}
\examples{
cli <- dq_client(
  api_url = "https://redcap.example.org/api/",
  token = "REDACTED",
  pid = 123,
  prefix = "vanderbilt_dataQuality"
)
}
