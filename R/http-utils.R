#' Private predicate function that checks if the protocol of a url
#' is https.
#'
#' @param x is a url string
is.https <- function(x) {
  m <- regexec("^https?://", x)
  matches <- regmatches(x, m)
  if (matches=="https://") {
    h <- TRUE
  } else {
    h <- FALSE
  }
  h
}

#' Private function for performing a GET request
#'
#' @param endpoint /path for REST request
#' @param query url parameters for request
promote.get <- function(endpoint, query=c()) {
  AUTH <- get("promote.config")
  if (length(AUTH)==0) {
    stop("Please specify your account credentials using promote.config.")
  }

  if ("env" %in% names(AUTH)) {
    url <- AUTH[["env"]]
    usetls <- FALSE
    if (is.https(url)) {
        usetls <- TRUE
    }
    url <- stringr::str_replace_all(url, "^https?://", "")
    url <- stringr::str_replace_all(url, "/$", "")
    if (usetls) {
      url <- sprintf("https://%s/", url)
    } else {
      url <- sprintf("http://%s/", url)
    }
    AUTH <- AUTH[!names(AUTH)=="env"]
    query <- paste(names(query), query, collapse="&", sep="=")
    url <- paste(url, endpoint, "?", query, sep="")
    httr::GET(url, httr::authenticate(AUTH[["username"]], AUTH[["apikey"]], 'basic'))
  } else {
    message("Please specify 'env' parameter in promote.config.")
  }
}

#' Private function for performing a POST request
#'
#' @param endpoint /path for REST request
#' @param query url parameters for request
#' @param data payload to be converted to raw JSON
#' @param silent should output of url to console be silenced?
#' Default is \code{FALSE}.
#' @param bulk is this a bulk style request? Default is \code{FALSE}.
promote.post <- function(endpoint, query=c(), data, silent = TRUE, bulk = FALSE) {
  if(!is.logical(silent)) stop("Argument 'silent' must be logical!")
  AUTH <- get("promote.config")
  if (length(AUTH)==0) {
    stop("Please specify your account credentials using promote.config.")
  }

  if ("env" %in% names(AUTH)) {
    url <- AUTH[["env"]]
    usetls <- FALSE
    if (is.https(url)) {
      usetls <- TRUE
    }
    url <- stringr::str_replace_all(url, "^https?://", "")
    url <- stringr::str_replace_all(url, "/$", "")
    if (usetls) {
      url <- sprintf("https://%s/", url)
    } else {
      url <- sprintf("http://%s/", url)
    }
    AUTH <- AUTH[!names(AUTH)=="env"]
    query <- c(query, AUTH)
    query <- paste(names(query), query, collapse="&", sep="=")
    url <- paste(url, endpoint, "?", query, sep="")
    if(silent==FALSE) {
      message(url)
    }

    # bullk sends back line delimited JSON
    if (bulk==TRUE) {
      out <- textConnection("data.json", "w")
      jsonlite::stream_out(data, con = out)
      close(out)
    } else {
      data.json <- jsonlite::toJSON(data, dataframe = "columns")
    }
    httr::POST(url, body = data.json,
                    config = c(
                      httr::authenticate(AUTH[["username"]], AUTH[["apikey"]], 'basic'),
                      httr::add_headers("Content-Type" = "application/json")
                      )
              )
  } else {
    message("Please specify 'env' parameter in promote.config.")
  }
}
