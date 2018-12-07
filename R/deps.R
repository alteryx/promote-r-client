#' Private function that adds a package to the list of dependencies
#' that will be installed on the Promote server
#' @param name name of the package to be installed
#' @param importName name under which the package is imported (for a github package,
#' this may be different from the name used to install it)
#' @param src source that the package is installed from (CRAN or github)
#' @param version version of the package
#' @param install whether or not the package should be installed in the model image
#' @param auth_token a personal access token for github or gitlab repositories
#' @param ref The git branch, tag, or SHA of the package to be installed
#' @param subdir The path to the repo subdirectory holding the package to be installed

add.dependency <- function(name, importName, src, version, install, auth_token, ref, subdir) {
  # nulls will break the data.frame/rbind 
  # but we don't want to pass a version or auth token if not necessary

  print(c(name, importName, src, version, install, auth_token, ref, subdir))
  # if (is.null(auth_token)) {
  #   auth_token <- NA
  # }

  # if (is.null(version)) {
  #   version <- NA
  # }

  # if (is.null(ref)) {
  #   version <- NA
  # }

  # if (is.null(subdir)) {
  #   version <- NA
  # }

  # if (src == "version") {
  #   ref <- NA
  # }

  # Don't add the dependency if it's already there, but if a package with the same importName is present,
  # make sure to enter the most recent arguments in case of ref or name update

  dependencies <- promote$dependencies

  if (!any(dependencies$importName == importName)) {
    newRow <- data.frame(name = name, importName = importName, src = src, version = version, install = install, auth_token = auth_token, ref = ref, subdir = subdir)
    dependencies <- rbind(dependencies, newRow)
    promote$dependencies <- dependencies
  } else {
    dependencies <- dependencies[importName != importName, ]
    newRow <- data.frame(name = name, importName = importName, src = src, version = version, install = install, auth_token = auth_token, ref = ref, subdir = subdir)
    dependencies <- rbind(dependencies, newRow)
    promote$dependencies <- dependencies
  }
}

#' Private function that generates a model.require function based on
#' the libraries that have been imported in this session.
set.model.require <- function() {
  imports <- promote$dependencies$importName
  promote$model.require <- function() {
    for (pkg in imports) {
      library(pkg, character.only = TRUE)
    }
  }
}

