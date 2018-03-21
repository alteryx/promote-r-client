# load the promote library
library(promote)

# create our predict function
# this is what is executed when the REST API is called
# `request` is a json object, parsed by jsonlite::fromJSON()
model.predict <- function(request) {
  me <- request$name
  greeting <- paste0("Hello ", me, "!")
  greeting
}

# test our predict function locally
# if this doesn't work locally, it wont work on Promote either
model.predict(jsonlite::fromJSON('{"name": "colin"}'))

# Setup the URL and authentication for deployment
promote.config  <- c(
  username = "USERNAME",
  apikey = "APIKEY",
  env = "PROMOTE_URL"
)

# name and deploy our model
promote.deploy("HelloWorld", confirm = FALSE)
