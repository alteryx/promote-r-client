## promote

## Installation

```r
install.packages("promote")
```

## Quick overview

There are 4 main parts to a model deployment:

1. read in the promote library
2. Create the `model.predict()` function i.e. the API 
3. Add any library dependencies: `promote.library('dplyr')`
4. Set the authentication with `promote.config`
5. Deploy!

```r
library(stringr)
library(promote)

model.predict <- function(request) {
  me <- request$name
  if(stringr::str_length(me) < 2){
    greeting <- "name too short"
  } else {
  greeting <- paste0("Hello ", me, "!")
  }
  greeting
}


promote.library('stringr')

promote.config  <- c(
  username = "YOUR_USERNAME",
  apikey = "YOUR_API_KEY",
  env = "PROMOTE_URL"
)

promote.deploy("HelloWorld", confirm = FALSE)
```