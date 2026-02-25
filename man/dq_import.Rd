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
\item export-shaped R list. For each query row, use keys:
\itemize{
\item \code{status_id}, \code{record}, \code{event_id}, \code{field_name}, \code{assigned_username}
\item \code{repeat_instrument}, \code{instance}, \code{project_id}
\item \code{resolutions} (named list), where each resolution includes:
\itemize{
\item \code{res_id}, \code{status_id}, \code{ts}, \code{response_requested}, \code{response}
\item \code{comment}, \code{current_query_status}, \code{username}
}
}
\item minimal data frame with columns:
\itemize{
\item required: \code{record}, \code{field_name}, \code{comment}, \code{username}
\item optional: \code{event_id} (defaults to \code{""}), \code{assigned_username}, \code{repeat_instrument}, \code{instance}
\item optional: \code{response_requested} (defaults to \code{"1"})
\item optional: \code{response} in \code{DATA_MISSING}, \code{TYPOGRAPHICAL_ERROR},
\code{CONFIRMED_CORRECT}, \code{WRONG_SOURCE}, \code{OTHER}, or blank
\item optional: \code{current_query_status} in \code{OPEN}, \code{CLOSED}, \code{VERIFIED},
\code{DEVERIFIED}, or blank (default is \code{OPEN})
\item optional: \code{status_id}
\item one query resolution payload row is created per data-frame row
}
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
