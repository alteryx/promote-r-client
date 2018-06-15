## promote

## Installation

```r
install.packages("promote")
```

## Usage

```r
library(promote)

model.predict <- function(request) {
  me <- request$name
  greeting <- paste0("Hello", me, "!")
  greeting
}

promote.metadata("NAME1",value1)
promote.metadata("NAME2",value2)

promote.config  <- c(
  username = "YOUR_USERNAME",
  apikey = "YOUR_API_KEY",
  env = "PROMOTE_URL"
)

promote.deploy("HelloWorld", confirm = FALSE)
```
