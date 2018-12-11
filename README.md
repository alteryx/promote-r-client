# Alteryx Promote R Client
Package for deploying R models to Alteryx Promote.

### Examples:
[Hello World](examples/helloworld) - A very simple model.

[Lending](examples/lending) - Use logistic regression to classify credit applications. as good or bad.

[xgboost](examples/xgboost) - Use xgboost to train a classifier on the agaricus dataset.
<hr>

## Installation
### Client
To install the promote package from CRAN, execute the following code from an active R session:
```r
install.packages("promote")
```

(Please refer to the [promote-python](https://github.com/alteryx/promote-python) package for instructions on installing the Python client.)

### Promote App
Please refer to the [installation guide](https://help.alteryx.com/promote/current/Administer/Installation.htm?tocpath=Administer%7C_____2) for instructions on installing the full Promote application.
<hr>

## Using the Client
### Model Directory Structure
```
example-model/
├── deploy.R
└── promote.sh (optional)
```

- [`deploy.R`](#deployr): our primary model deployment script

- [`promote.sh`](#promotesh): this file is executed before your model is built. It can be used to install low-level system packages such as Linux packages
<hr>

## Deploying Your Model

This section will walk through the steps and key functions of a successful `deploy.r` script. 
#### Steps:
- [Initial Setup](#setup)
- [model.predict](#modelpredict)
- [Test Data](#testing)
- [promote.library](#promotelibrary)
- [promote.metadata](#promotemetadata)
- [promote.config](#promoteconfig)
- [promote.deploy](#promotedeploy)
<hr>

### <a name="setup"></a>Initial Setup
Load the `promote` library that was previously installed:
```r
library(promote)
```

Import a saved model object:
```r
# Previously saved model 'save(my_model, file = "my_model.rda")'
load("my_model.rda")
```
<hr>

### `model.predict`
The `model.predict` function is used to define the API endpoint for a model and is executed each time a model is called. **This is the core of the API endpoint**

### Usage
`model.predict(data)`

### Arguments
- `data` the data frame generated from the JSON sent to the deployed model

**Example:**
```r
model.predict <- function(data) {
  # generate predictions from the model based on the incoming dataframe
  predict(my_model, data)
}
```

### <a name="testing"></a>Test Data
It is a good practice to test the `model.predict` function as part of the deployment script to make sure it successfully produces an output. Once deployed, the `data` argument passed to the `model.predict` function will always be in the form of an R [data frame](https://stat.ethz.ch/R-manual/R-devel/library/base/html/data.frame.html). The incoming JSON will be converted to a data frame using the `fromJSON()` method available from either [jsonlite](https://cran.r-project.org/web/packages/jsonlite/jsonlite.pdf) or [rjson](https://cran.r-project.org/web/packages/rjson/rjson.pdf). Which library is used can be configured in the advanced model management section of the Promote App.

**Example:**
```r
testdata <- '{"X1":[1,2,3],"X2":[4,5,6]}'
model.predict(data.frame(jsonlite::fromJSON(testdata),stringsAsFactors=TRUE))

```
<hr>

### `promote.library`

### Usage

`promote.library(name, src = "version", version = NULL, user = NULL, install = TRUE, auth_token = NULL, url = NULL, ref = "master", subdir = NULL)`

### Arguments

 - `name`	name of the package to be added
- `src`	source from which the package will be installed on Promote (CRAN (version) or git)
- `version`	version of the package to be added
- `user`	Github username associated with the package
- `install`	whether the package should also be installed into the model on the Promote server; this is typically set to False when the package has already been added to the Promote base image.
- `auth_token` Personal access token string associated with a private package's repository (only works when `src = 'github'`, recommended usage is to include PAT in the URL parameter while using `src='git'`)
- `url` A valid URL pointing to a remote hosted git repository (recommended)
- `ref`	The git branch, tag, or SHA of the package to be installed (SHA recommended)
- `subdir` The subdirectory of a git repository holding the package to install

**Examples:**

Public Repositories:
```r
promote.library("randomforest")

promote.library(c("wesanderson", "stringr"))

promote.library("my_public_package", install = FALSE)

promote.library("my_public_package", 
                src = "git", 
                url = "https://gitlab.com/userName/rpkg.git")

promote.library("hilaryparker/cats")

promote.library("cats", src = "github", user = "hilaryparker")
```

Private Repositories:
```r
promote.library("priv_pkg", 
                src = "git", 
                url = "https://x-access-token:<YourToken>ATgithub.com/username/rpkg.git")

promote.library("priv_pkg", 
                 src = "git", 
                 url = "https://x-access-token:<YourToken>ATgitlab.com/username/rpkg.git", 
                 ref = "i2706b2a9f0c2f80f9c2a90ac4499a80280b3f8d")

promote.library("priv_pkg", 
                 src = "git", 
                 url = "https://x-access-token:<YourToken>ATgitlab.com/username/rpkg.git", 
                 ref = "staging")

promote.library("cats", src = "github", user = "hilaryparker", auth_token = "3HwjSeMu1ynrYtc1e4yj") 
```
<hr>


### `promote.metadata`
Store custom metadata about a model as part of the `model.predict` call when it is sent to the Promote servers. (limited to 6 key-value pairs)

### Usage
`promote.metadata(name, value)`

### Arguments
- `name` the name of your metadata (limit 20 characters)
- `value` a value for your metadata (will be converted to string and limited to 50 characters)

**Example:**
```r
promote.metadata("one", 1)
promote.metadata("two", "2")
promote.metadata("list", list(a=1,b=2))
```
<hr>

### `promote.config`
To deploy models, add a username, API key, and URL to the `promote.config` variable

- `username` the username used to sign into the Promote app
- `apikey` the random API key that is assigned to that username
- `env` the URL that can be used to access the Promote app's frontend

**Example:**
```r
promote.config <- c(
  username = "username",
  apikey = "apikey",
  env = "http://promote.company.com/"
)
```
<hr>

### `promote.deploy`
The deploy function captures `model.predict` and the `promote.sh` file and sends them to the Promote servers

### Usage
`promote.deploy(model_name, confirm = TRUE, custom_image = NULL)`

### Arguments
- `model_name` the name of the model to deploy to Alteryx Promote
- `confirm` if true, the user will be prompted to confirm deployment 
- `custom_image` the custom image tag to use when building the model

**Example:**
```r
promote.deploy("MyFirstRModel", confirm = TRUE, custom_image = NULL)
```
<hr>

### `promote.sh`
The `promote.sh` file can be included in your model directory. It is executed before your model is built and can be used to install low-level system packages such as Linux packages and other dependencies. Be aware of the current working directory for your R session when deploying to ensure the deployment finds and processes the `promote.sh` file.

**Example:**
```shell
# Install Microsoft SQL Server RHEL7 ODBC Driver
curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo

exit
yum remove unixODBC-utf16 unixODBC-utf16-devel #to avoid conflicts
ACCEPT_EULA=Y yum install msodbcsql17
# optional: for bcp and sqlcmd
ACCEPT_EULA=Y yum install mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
```
<hr>

### Deployment
There are multiple ways to run your `deploy.R` script and deploy your model.
1. In in an active R shell session, you can source the deploy.R file.
```r
source("deploy.R")
```

2. If in a console/terminal/bash session, you can use the `Rscript` utility to run the file.
```shell
Rscript deploy.R
```

3. If using an R IDE environment like [RStudio](https://www.rstudio.com/), you can run or source the script all at once or selectively. Model deployment will once the `promote.deploy` function is called.
