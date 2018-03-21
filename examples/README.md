## promote

## Installation

```r
install.packages("promote")
```

## Quick overview

Deploying a predictive model takes 5 parts:

1. Load in the promote library: `library(promote)`
2. Create a `model.predict` function
3. Add any libraries the model requires `promote.library('dplyr')`
4. Setup the authentication with `promote.config`
5. Deploy the model: `promote.deploy`

## Usage

```r
library(promote)
library(stringi)


model.predict <- function(request) {
  me <- request$name
  if(stringi::stri_length(me) < 2) {
      greeting <- "name is too short"
  } else {
    greeting <- paste0("Hello ", me, "!")
  }
  greeting
}

# test it locally
model.predict(fromJSON('{"name":"c"}'))

# add our package dependency
promote.library('stringi')

promote.config  <- c(
  username = "USERNAME",
  apikey = "API_KEY",
  env = "PROMOTE_URL"
)

promote.deploy("HelloWorld", confirm = FALSE)
```
