#' R language tour
#'
#' Covers vectors, lists, data frames, S3/S4 classes, closures,
#' the pipe operator, apply functions and formulas.
#'
#' @name languagetour
NULL

# Severity levels for a log line.
SEVERITY <- c(debug = 1L, info = 2L, warning = 3L, error = 4L)

#' Create a log entry
#'
#' @param message character. The human readable text.
#' @param severity character. One of names(SEVERITY).
#' @param tags character vector. Optional labels.
#' @return An object of class \code{log_entry}.
#' @examples
#' log_entry("hello", "error")
#' @export
log_entry <- function(message, severity = "info", tags = character(0)) {
  stopifnot(is.character(message), nchar(message) > 0)

  structure(
    list(message = message, severity = severity, tags = tags), # inline comment
    class = "log_entry"
  )
}

#' @export
print.log_entry <- function(x, ...) {
  cat(sprintf("[%s] %s (%d tags)\n", x$severity, x$message, length(x$tags)))
  invisible(x)
}

setClass(
  "LogRepository",
  representation(store = "list"),
  prototype(store = list())
)

setGeneric("findById", function(object, id) standardGeneric("findById"))

setMethod("findById", "LogRepository", function(object, id) {
  if (as.character(id) %in% names(object@store)) object@store[[as.character(id)]] else NULL
})

#' Most recent severe messages
#'
#' @param entries list of log_entry objects
#' @param take integer. Maximum results.
#' @return character vector
recent <- function(entries, take = 5L) {
  severe <- Filter(function(e) SEVERITY[[e$severity]] >= 3L, entries)
  messages <- vapply(severe, function(e) e$message, character(1))
  head(messages, take)
}

describe <- function(count, severity) {
  if (count == 0L) {
    "empty"
  } else if (identical(severity, "error")) {
    "failing"
  } else if (count > 100L) {
    "busy"
  } else {
    "ok"
  }
}

df <- data.frame(
  id = 1:3,
  severity = c("info", "error", "warning"),
  stringsAsFactors = FALSE
)
agg <- aggregate(id ~ severity, data = df, FUN = length)
