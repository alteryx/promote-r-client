# Altery Promote R Client
R package for deploying models buiult using R to Altery Promote

### Installation

```r
install.packages("promote")
```

### Example Models
[Hello World](examples/helloworld) - a very simple model

[Lending](examples/lending) - Use logistic regression to classify credit applications as good or bad

[xgboost](examples/xgboost) - Use xgboost to train a classifier on the agaricus dataset

### Project Overview

In order for all of your model dependencies to be transfered over to Alteryx Promote, you must follow a particular structure.

#### Example model directory structure:
```
example-model/
├── promote.sh
└── main.R (our deployment script)
```

`promote.sh` - this file is executed before your model is built. It can be used to install low-level system packages such as Linux packages

`main.R` - our primary model deployment script

## Building a model:

Before beginning building a model, be sure to import the `promote` package:

`libary(promote)`

### The `model.predict()` function

The `model.predict` function is used o define the API endpoint for a model and is executed each time a model is called. **This is the core of the API endpoint**

```r
# import the promote package and define our model function
library(promote)

model.predict <- function(request) {
  me <- request$name
  greeting <- paste0("Hello", me, "!")
  greeting
}

# add metadata to attach to this model version
promote.metadata("NAME1",value1)
promote.metadata("NAME2",value2)

# specify the username, apikey and url, and then deploy
promote.config  <- c(
  username = "YOUR_USERNAME",
  apikey = "YOUR_API_KEY",
  env = "PROMOTE_URL"
)

promote.deploy("HelloWorld", confirm = FALSE)
```

<hr>
### Setting the Auth

To deploy models, you'll need to add your username, API key, and URL to the `promote.config` variable
```r
promote.config <- c(
  username = [USERNAME],
  apikey = [APIKEY],
  env = [URL]
)
```
<hr>

### `Promote`

The `Promote` packages has 3 methods:
- [`promote.deploy`](#promotedeploy)
- [`promote.metadata`](#promotemetadata)
- [`promote.library`](#promotelibrary)

### `promote.deploy()`

#### Deploy a model to Alteryx Promote

The `deploy function captures `model.predict()` and the `promote.sh` file and sends them to the Promote servers

#### Usage

`promote.deploy(name,confirm=False)

#### Arguments
- `name`(_string_): the name of the model to deploy to Alteryx Promote
- `confirm`(_boolean_, optional): If `TRUE`, then user will be prompted to confirm deployment

#### Examples

Deploy the "IrisClassifier_model" and don't require confirmation on deployment.
```r
promote.deploy("IrisClassifier_model",confirm=FALSE)
```
<hr>

### `promote.metadata()``

Store custom metadta about amoel as part of the `model.predict()` when it is sent to the Promote servers. (limited to 6 key-value pairs)

#### Usage

`promote.metadata(name, value)`

#### Arguments
- `name`(_string_): the name of your metadata (limit 20 characters)
- `value`: a value for your metadata (will be converted to string and limited to 50 characters)

#### Examples

```r
promote.metadata("one", 1)
promote.metadata("two","2")
promote.metadata("list",list(a=1,b=2))
```
<hr>
### `promote.library()`

Tell the Promote servers to install a package needed to run `model.predict()`

#### Usage

`promote.library(package)`

#### Arguments

- 'package'(_string_): the name of the package to install on the Promoter server

#### Examples

```r
promote.library("randomforest")
promote.library("plyr")
```
