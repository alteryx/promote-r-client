library(devtools)
# devtools::install_github("gaborcsardi/dotenv")
library(dotenv)

library(promote)

model.predict <- function(request) {
  me <- request$name
  greeting <- paste ("Hello", me, "!")
  greeting
}

promote.config  <- c(
  username = Sys.getenv("PROMOTE_USERNAME"),
  apikey = Sys.getenv("PROMOTE_APIKEY"),
  env = Sys.getenv("PROMOTE_URL")
)

promote.deploy("HelloWorldTest", confirm = FALSE)
TESTDATA <- c("name":"colin")

promote.predict("HelloWorldTest", TESTDATA)