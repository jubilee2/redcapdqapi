build_open_import_payload <- function(data, project_id = NULL) {
  required_cols <- c("record", "event_id", "field_name", "comment", "assigned_username")
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
    out[[i]] <- build_open_import_row(data, i, project_id = project_id)
  }
  names(out) <- as.character(seq_len(nrow(data)))

  out
}

build_open_import_row <- function(data, i, project_id = NULL) {
  record <- required_df_string(data, i, "record")
  event_id <- required_df_string(data, i, "event_id")
  field_name <- required_df_string(data, i, "field_name")
  comment <- required_df_string(data, i, "comment")
  assigned_username <- required_df_string(data, i, "assigned_username")
  username <- optional_df_string(data, i, "username", default = assigned_username)

  list(
    status_id = NULL,
    rule_id = NULL,
    pd_rule_id = NULL,
    non_rule = "1",
    project_id = if (is.null(project_id)) NULL else as.character(project_id),
    record = record,
    event_id = event_id,
    field_name = field_name,
    repeat_instrument = optional_df_string(data, i, "repeat_instrument", default = NULL),
    instance = optional_df_string(data, i, "instance", default = "1"),
    status = NULL,
    exclude = optional_df_string(data, i, "exclude", default = "0"),
    query_status = "OPEN",
    group_id = optional_df_string(data, i, "group_id", default = NULL),
    assigned_username = assigned_username,
    resolutions = list(
      "1" = list(
        res_id = NULL,
        status_id = NULL,
        ts = current_import_timestamp(),
        response_requested = optional_df_string(data, i, "response_requested", default = "0"),
        response = NULL,
        comment = comment,
        current_query_status = "OPEN",
        upload_doc_id = NULL,
        field_comment_edited = "0",
        migration_status = NULL,
        migration_doc_id = NULL,
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
