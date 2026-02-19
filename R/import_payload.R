build_import_payload <- function(data, project_id = NULL) {
  required_cols <- c("record", "field_name", "comment", "username")
  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    stop(
      sprintf(
        "`data` data frame is missing required columns: %s.",
        paste(missing, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  if (nrow(data) == 0) {
    stop("`data` data frame must contain at least one row.", call. = FALSE)
  }

  out <- vector("list", nrow(data))
  for (i in seq_len(nrow(data))) {
    out[[i]] <- build_import_row(data, i, project_id = project_id)
  }
  names(out) <- as.character(seq_len(nrow(data)))

  out
}

build_import_row <- function(data, i, project_id = NULL) {
  record <- required_df_string(data, i, "record")
  event_id <- optional_df_string(data, i, "event_id", default = "1")
  field_name <- required_df_string(data, i, "field_name")
  comment <- required_df_string(data, i, "comment")
  assigned_username <- optional_df_string(data, i, "assigned_username", default = NULL)
  username <- required_df_string(data, i, "username")
  status_id <- optional_df_string(data, i, "status_id", default = "")

  list(
    status_id = status_id,
    project_id = if (is.null(project_id)) NULL else as.character(project_id),
    record = record,
    event_id = event_id,
    field_name = field_name,
    repeat_instrument = optional_df_string(data, i, "repeat_instrument", default = NULL),
    instance = optional_df_string(data, i, "instance", default = "1"),
    assigned_username = assigned_username,
    resolutions = list(
      "1" = list(
        res_id = "",
        status_id = status_id,
        ts = current_import_timestamp(),
        response_requested = optional_df_string(data, i, "response_requested", default = "0"),
        response = NULL,
        comment = comment,
        current_query_status = "OPEN",
        username = username
      )
    )
  )
}

required_df_string <- function(data, i, col_name) {
  value <- optional_df_string(data, i, col_name, default = NULL)
  if (is.null(value) || !nzchar(value)) {
    stop(
      sprintf(
        "`data$%s` must be non-empty for row %s.",
        col_name,
        i
      ),
      call. = FALSE
    )
  }
  value
}

current_import_timestamp <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}

optional_df_string <- function(data, i, col_name, default = NULL) {
  if (!col_name %in% names(data)) {
    return(default)
  }

  value <- data[[col_name]][[i]]
  if (length(value) == 0 || is.na(value)) {
    return(default)
  }

  value <- as.character(value)[[1]]
  if (!nzchar(value)) {
    return(default)
  }

  value
}
