#' Private function that adds metadata about the model
#' that will be installed on the Promote server
#' the metadata is arranged as key-value pairs
#' @param key key name for the metadata entry
#' @param value value for the metadata entry

add.metadata <- function(key, value) {
  # Don't add the dependency if it's already there
  metadata <- promote$metadata
  if (!any(metadata$key == key)) {
    newRow <- data.frame(key = key, value = value)
    metadata <- rbind(metadata, newRow)
    promote$metadata <- metadata
  }
}
