# Create a new environment in order to namespace variables that hold the package state
promote <- new.env(parent = emptyenv())

# Packages that need to be installed for the model to run - this will almost always
# include all the packages listed in imports
promote$dependencies <- data.frame()

# Metadata from the model
promote$metadata <- data.frame()

# Private function for storing requirements that will be imported on
# the Promote server
promote$model.require <- function() {
}

#' Calls promote's REST API and returns a JSON document containing both the prediction
#' and associated metadata.
#'
#' @param model_name the name of the model you want to call
#' @param data input data for the model
#' @param model_owner the owner of the model [optional]
#' @param raw_input when true, incoming data will NOT be coerced into data.frame
#' @param silent should output of url to console (via \code{promote.post})
#' be silenced? Default is \code{FALSE}.
#'
#' @export
#' @examples
#' promote.config <- c(
#'  username = "your username",
#'  apikey = "your apikey",
#'  env="http://ip_of_alteryx_promote.com"
#' )
#' \dontrun{
#' promote.predict_raw("irisModel", iris)
#' }
promote.predict_raw <- function(model_name, data, model_owner, raw_input = FALSE, silent = TRUE) {
  usage <- "usage:  promote.predict(<model_name>,<data>)"
  if (missing(model_name)){
    stop(paste("Please specify the model name you'd like to call", usage, sep = "\n"))
  }
  if (missing(data)){
    stop(paste("You didn't pass any data to predict on!", usage, sep = "\n"))
  }
  AUTH <- get("promote.config")
  if ("env" %in% names(AUTH)) {
    user <- AUTH[["username"]]
    if (!missing(model_owner)){
      user <- model_owner
    }
    endpoint <- sprintf("%s/models/%s/predict", user, model_name)
  } else {
    stop("Please specify an env in promote.config")
  }

  # build the model url for the error message
  url <- AUTH[["env"]]
  usetls <- FALSE
  if (is.https(url)) {
    usetls <- TRUE
  }
  url <- stringr::str_replace_all(url, "^https?://", "")
  url <- stringr::str_replace_all(url, "/$", "")
  if (usetls) {
    model_url <- sprintf("https://%s/model/%s", url, model_name)
  } else {
    model_url <- sprintf("http://%s/model/%s", url, model_name)
  }
  query <- list()
  if (raw_input == TRUE) {
    query[["raw_input"]] <- "true"
  }

  error_msg <- paste("Invalid response: are you sure your model is built?\nHead over to",
                     model_url, "to see you model's current status.")
  tryCatch(
    {
      rsp <- promote.post(endpoint, query = query, data = data, silent = silent)
      httr::content(rsp)
    },
    error = function(e){
      print(e)
      stop(error_msg)
    },
    exception = function(e){
      print(e)
      stop(error_msg)
    }
  )
}
#' Make a prediction using promote.
#'
#' This function calls promote's REST API and returns a response formatted as a
#' data frame.
#'
#' @param model_name the name of the model you want to call
#' @param data input data for the model
#' @param model_owner the owner of the model [optional]
#' @param raw_input when true, incoming data will NOT be coerced into data.frame
#' @param silent should output of url to console (via \code{promote.post})
#' be silenced? Default is \code{FALSE}.
#'
#' @keywords predict
#' @export
#' @examples
#' promote.config <- c(
#'  username = "your username",
#'  apikey = "your apikey",
#'  env = "http://sandbox.promotehq.com/"
#' )
#' \dontrun{
#' promote.predict("irisModel", iris)
#' }
promote.predict <- function(model_name, data, model_owner, raw_input = FALSE, silent = TRUE) {
  raw_rsp <- promote.predict_raw(model_name, data, model_owner, raw_input = raw_input, silent = silent)
  tryCatch({
    if (raw_input == TRUE) {
      raw_rsp
    } else if ("result" %in% names(raw_rsp)) {
      data.frame(lapply(raw_rsp$result, unlist))
    } else {
      data.frame(raw_rsp)
    }
  },
  error = function(e){
    stop("Invalid response: are you sure your model is built?")
  },
  exception = function(e){
    stop("Invalid response: are you sure your model is built?")
  })
}

#' Import one or more libraries and add them to the promote model's
#' dependency list
#'
#' @param name name of the package to be added
#' @param src source from which the package will be installed on Promote (github or CRAN)
#' @param version version of the package to be added
#' @param user Github username associated with the package
#' @param install Whether the package should also be installed into the model on the
#' Promote server; this is typically set to False when the package has already been
#' added to the Promote base image.
#' @keywords import
#' @export
#' @examples
#' \dontrun{
#' promote.library("MASS")
#' promote.library(c("wesanderson", "stringr"))
#' promote.library("cats", src="github", user="hilaryparker")
#' promote.library("hilaryparker/cats")
#' promote.library("my_proprietary_package", install=FALSE)
#' }
#' @importFrom utils packageDescription
promote.library <- function(name, src="version", version=NULL, user=NULL, install=TRUE, auth_token=NULL) {

  # If a vector of CRAN packages is passed, add each of them
  if (length(name) > 1) {
    for (n in name) {
      promote.library(n, src=src, version=version, user=user, install=install, auth_token=auth_token)
    }
    return()
  }

  # if someone manually passes "CRAN" as src, set it to version to match the templating
  if (src == "CRAN") {
    src <- "version"
  }

  # Make sure it's using an accepted src
  if (!src %in% c("version", "CRAN", "github", "gitlab", "bitbucket")) {
    stop(cat(src, "is not a valid package type"))
  }

# This is to support the legacy implementation of github (public only) installs
  if (!grepl("/", name) && src %in% c("github", "gitlab", "bitbucket")) {
    if (is.null(user)) {
      stop(cat("no repository username specified"))
    }
    installName <- paste(user, "/", name, sep="")
  } else {
    installName <- name
  }

  if (grepl("/", name)) {
    nameAndUser <- unlist(strsplit(name, "/"))
    user <- nameAndUser[[1]]
    name <- nameAndUser[[2]]
  }

 library(name, character.only = TRUE)

  # If a version wasn't manually specified for a CRAN install, get this info from the session
  if (src=="version" && is.null(version)) {
    version <- packageDescription(name)$Version
  }

  add.dependency(installName, name, src, version, install, auth_token)

  set.model.require()
}

#' Add metadata to the deployment of your promote model
#'
#' @param name key name for the metadata entry
#' @param value value for the metadata entry
#' @keywords metadata
#' @export
#' @examples
#' \dontrun{
#' promote.metadata("key", "value")
#' promote.metadata("R_squared", summary(fit)$r.squared)
#' promote.metadata("R_squared_adj", summary(fit)$adj.r.squared)
#' promote.metadata("deploy_node", Sys.info()[["nodename"]])
#' }
#' @importFrom utils packageDescription
promote.metadata <- function(name, value) {
  if (is.null(name)) {
    stop("promote.metadata requires a 'name' field")
  }
  if (is.null(value)) {
    stop("promote.metadata requires a 'value' field")
  }
  if (typeof(name) != "character") {
    stop("promote.metadata name must be a character type")
  }
  if (typeof(value) != "character") {
    value <- toString(value)
  }
  if (nchar(name) > 21) {
    stop("please limit your name field to 20 characters or less")
  }
   if (nchar(value) > 51) {
    stop("please limit your value field to 50 characters or less")
  }
  add.metadata(name, value)
}

#' Removes a library from the promote model's dependency list
#'
#' @param name of the package to be removed
#'
#' @export
#' @examples
#' \dontrun{
#' promote.unload("wesanderson")
#' }
promote.unload <- function(name) {
  deps <- promote$dependencies
  promote$dependencies <- deps[deps$importName != name, ]
  set.model.require()
}

#' Deploy a model to promote's servers
#'
#' This function takes model.predict and creates
#' a model on promote's servers which can be called from any programming language
#' via promote's REST API (see \code{\link{promote.predict}}).
#'
#' @param model_name name of your model
#' @param confirm boolean indicating whether to prompt before deploying
#' @param custom_image name of the image you'd like your model to use
#' @keywords deploy
#' @export
#' @examples
#' promote.config <- c(
#'  username = "your username",
#'  apikey = "your apikey",
#'  env = "http://sandbox.promotehq.com/"
#' )
#' iris$Sepal.Width_sq <- iris$Sepal.Width^2
#' fit <- glm(I(Species)=="virginica" ~ ., data=iris)
#'
#' model.predict <- function(df) {
#'  data.frame("prediction"=predict(fit, df, type="response"))
#' }
#' \dontrun{
#' promote.library("randomForest")
#' promote.deploy("irisModel")
#' }
promote.deploy <- function(model_name, confirm=TRUE, custom_image=NULL) {
  if (missing(model_name)){
    stop("Please specify 'model_name' argument")
  }
  if (length(grep("^[A-Za-z0-9]+$", model_name))==0) {
    stop("Model name can only contain following characters: A-Za-z0-9")
  }
  img.size.mb <- check.image.size()
  AUTH <- get("promote.config")
  if (length(AUTH) == 0) {
    stop("Please specify your account credentials using promote.config.")
  }
  if (nrow(promote$metadata) > 6) {
    stop("promote.metadata allows a maximum of 6 items")
  }


  if ("env" %in% names(AUTH)) {
    env <- AUTH[["env"]]
    usetls <- FALSE
    if (is.https(env)) {
      usetls <- TRUE
    }
    env <- stringr::str_replace_all(env, "^https?://", "")
    env <- stringr::str_replace_all(env, "/$", "")
    AUTH <- AUTH[!names(AUTH)=="env"]
    if (usetls) {
      url <- sprintf("https://%s/api/deploy/R", env)
    } else {
      url <- sprintf("http://%s/api/deploy/R", env)
    }
    image_file <- tempfile(pattern = "scienceops_deployment")

    all_objects <- promote.ls()
    # Consolidate local environment with global one
    deployEnv <- new.env(parent = emptyenv())
    deployEnv$model.require <- promote$model.require
    for (obj in all_objects) {
      deployEnv[[obj]] <- globalenv()[[obj]]
    }

    all_funcs <- all_objects[lapply(all_objects, function(name){
      class(globalenv()[[name]])
    }) == "function"]
    all_objects <- c("model.require", all_objects)

    save(list=all_objects, envir = deployEnv, file = image_file)
    cat("objects detected\n")

    sizes <- lapply(all_objects, function(name) {
      format( object.size(globalenv()[[name]]) , units = "auto")
    })
    sizes <- unlist(sizes)
    print(data.frame(name = all_objects, size = sizes))
    cat("\n")

    if (confirm && interactive()) {
      confirm.deployment()
    }

    dependencies <- promote$dependencies[promote$dependencies$install,]
    print(dependencies)
    metadata <- promote$metadata

    body <- list(
      "model_image" = httr::upload_file(image_file),
      "modelname" = model_name,
      "packages" = jsonlite::toJSON(dependencies),
      "code" = capture.src(all_funcs),
      "custom_image" = custom_image,
      "metadata" = jsonlite::toJSON(metadata)
    )

    promotesh <- paste(getwd(), "/promote.sh", sep = "")
    if (file.exists(promotesh)) {
      con <- file(promotesh)
      out <- paste(c(readLines(con)), collapse="\n")
      close(con)
      body[["promotesh"]] <- out
    }

    err.msg <- paste("Could not connect to Promote. Please ensure that your",
                     "specified server is online. Contact info [at] promotehq [dot] com",
                     "for further support.",
                     "-----------------------",
                     "Specified endpoint:",
                     env,
                     sep="\n")
    rsp <- httr::POST(url, httr::authenticate(AUTH[["username"]], AUTH[["apikey"]], 'basic'), body = body)

    body <- httr::content(rsp)
    if (rsp$status_code != 200) {
      unlink(image_file)
      stop("deployment error: ", body)
    }
    rsp.df <- data.frame(body)
    unlink(image_file)
    cat("deployment successful\n")
    rsp.df
  } else {
    message("Please specify 'env' parameter in promote.config.")
  }
}
