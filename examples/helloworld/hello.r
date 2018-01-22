#install.packages('promote')
library(promote)
library(jsonlite)

model.predict <- function(request) {
  me <- request$name
  greeting <- paste0("Hello ", me, "!")
  greeting
}

# test you model locally
TESTDATA <- jsonlite::fromJSON('{"name": "colin"}')
model.predict(TESTDATA)

promote.config  <- c(
  username = "your_username",
  apikey = "your_APIKEY",
  env = "https://promote_url.com"
)

promote.deploy("HelloWorld", confirm = FALSE)
