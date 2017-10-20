library(promote)

model.predict <- function(request) {
  me <- request$name
  greeting <- paste0("Hello", me, "!")
  greeting
}

promote.config  <- c(
  username = "colin",
  apikey = "d325fc5bcb83fc197ee01edb58b4b396",
  env = "https://sandbox.c.yhat.com"
)

promote.deploy("HelloWorld_PromoteTest", confirm = FALSE)
