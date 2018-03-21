library(promote)

model.predict <- function(request) {
  me <- request$name
  greeting <- paste0("Hello ", me, "!")
  greeting
}

testJSON <- '{"name": "colin"}'
test <- rjson::fromJSON(testJSON)

model.predict(test)

promote.config  <- c(
  username = "USERNAME",
  apikey = "APIKEY",
  env = "PROMOTE_URL"
)

promote.deploy("HelloWorld", confirm = FALSE)
