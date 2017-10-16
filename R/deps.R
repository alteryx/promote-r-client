#' Private function that adds a package to the list of dependencies
#' that will be installed on the ScienceOps server
#' @param name name of the package to be installed
#' @param importName name under which the package is imported (for a github package,
#' this may be different from the name used to install it)
#' @param src source that the package is installed from (CRAN or github)
#' @param version version of the package
#' @param install whether or not the package should be installed in the model image
add.dependency <- function(name, importName, src, version, install) {
  # Don't add the dependency if it's already there
  dependencies <- promote$dependencies
  if (!any(dependencies$name == name)) {
    newRow <- data.frame(name=name, importName=importName, src=src, version=version, install=install)
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


