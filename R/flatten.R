#' Flatten exported data quality payload
#'
#' Pure transformation helper for `dq_export()` payloads.
#'
#' @param x A `dq_export` object or a parsed export list.
#'
#' @return A list with `status` and `resolutions` data frames.
#' @examples
#' fixture <- dq_read_json(system.file("extdata", "example_export.json", package = "redcapdqapi"))
#' out <- dq_flatten(fixture)
#' names(out)
#' @export
dq_flatten <- function(x) {
  data <- normalize_export_data(x)

  status_cols <- c(
    "status_id", "rule_id", "pd_rule_id", "non_rule", "project_id", "record",
    "event_id", "field_name", "repeat_instrument", "instance", "status", "exclude",
    "query_status", "group_id", "assigned_username"
  )

  resolution_cols <- c(
    "res_id", "status_id", "ts", "response_requested", "response", "comment",
    "current_query_status", "upload_doc_id", "field_comment_edited",
    "migration_status", "migration_doc_id", "username"
  )

  if (length(data) == 0) {
    return(list(
      status = tibble::as_tibble(stats::setNames(replicate(length(status_cols), logical(0), simplify = FALSE), status_cols)),
      resolutions = tibble::as_tibble(stats::setNames(replicate(length(resolution_cols), logical(0), simplify = FALSE), resolution_cols))
    ))
  }

  status_rows <- vector("list", length(data))
  resolution_rows <- list()

  index <- 1
  for (item in data) {
    status <- item
    resolutions <- status$resolutions
    status$resolutions <- NULL

    if (is.null(status$status_id) || !nzchar(as.character(status$status_id))) {
      status$status_id <- NA_character_
    }

    status_rows[[index]] <- status
    index <- index + 1

    if (!is.null(resolutions) && length(resolutions) > 0) {
      for (resolution in resolutions) {
        resolution_rows[[length(resolution_rows) + 1]] <- resolution
      }
    }
  }

  status_df <- tibble::as_tibble(do.call(rbind_fill_base, lapply(status_rows, list_to_one_row_df)))
  status_df <- enforce_columns(status_df, status_cols)

  if (length(resolution_rows) == 0) {
    resolutions_df <- tibble::as_tibble(stats::setNames(replicate(length(resolution_cols), logical(0), simplify = FALSE), resolution_cols))
  } else {
    resolutions_df <- tibble::as_tibble(do.call(rbind_fill_base, lapply(resolution_rows, list_to_one_row_df)))
    resolutions_df <- enforce_columns(resolutions_df, resolution_cols)
  }

  list(status = status_df, resolutions = resolutions_df)
}

normalize_export_data <- function(x) {
  if (inherits(x, "dq_export")) {
    return(x$data)
  }
  if (is.list(x)) {
    return(x)
  }
  stop("`x` must be a dq_export object or parsed list.", call. = FALSE)
}

enforce_columns <- function(df, cols) {
  for (col in cols) {
    if (!col %in% names(df)) {
      df[[col]] <- NA
    }
  }
  df[, cols, drop = FALSE]
}

rbind_fill_base <- function(...) {
  frames <- list(...)
  if (length(frames) == 1 && is.list(frames[[1]]) && !inherits(frames[[1]], "data.frame")) {
    frames <- frames[[1]]
  }

  all_names <- unique(unlist(lapply(frames, names)))
  frames <- lapply(frames, function(df) {
    missing <- setdiff(all_names, names(df))
    for (m in missing) df[[m]] <- NA
    df[, all_names, drop = FALSE]
  })
  do.call(rbind, frames)
}


list_to_one_row_df <- function(x) {
  x <- lapply(x, function(value) {
    if (is.null(value) || length(value) == 0) {
      return(NA)
    }

    if (is.atomic(value) && length(value) == 1) {
      return(value)
    }

    as.character(value)
  })

  as.data.frame(x, stringsAsFactors = FALSE)
}
