#' Private function for checking the size of the user's image.
#'
#' @importFrom utils object.size
check.image.size <- function() {
  bytes.in.a.mb <- 2 ^ 20
  model.size <- list()
  for (obj in promote.ls()) {
    model.size[[obj]] <- object.size(get(obj))
  }
  # lets get this into a data.frame
  df <- data.frame(unlist(model.size))
  model.size <- data.frame(obj=rownames(df),size.mb=df[[1]] / bytes.in.a.mb)
  model.size
}

confirm.deployment <- function() {
  deps <- promote$dependencies
  deps$importName <- NULL
  cat("Model will be deployed with the following dependencies:\n")
  print(deps)
  needsConfirm <- TRUE
  while (needsConfirm) {
      sure <- tolower(readline("Are you sure you want to deploy? y/n "))
      if sure == "n" {
        needsConfirm <- FALSE
        stop("Deployment cancelled")
      } else if sure == "y" {
        needsConfirm <- FALSE
      }
    }
}

