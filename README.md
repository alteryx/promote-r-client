# Alteryx Promote R Client
Package for deploying models built using R to Alteryx Promote

## Examples
[Hello World](examples/helloworld) - a very simple model

[Lending](examples/lending) - Use logistic regression to classify credit applications as good or bad

[xgboost](examples/xgboost) - Use xgboost to train a classifier on the agaricus dataset

## Installation
### Client
To install the promote library from CRAN, execute the following code from an active R session.
```r
install.packages("promote")
```

Please refer to the [promote-python](https://github.com/alteryx/promote-python) package for instructions on installing the Python Client.

### App
Please refer to the [installation guide](https://help.alteryx.com/promote/current/Administer/Installation.htm?tocpath=Administer%7C_____2) for instructions on installing the Promote App.

## Usage
### Model Directory Structure
```
example-model/
├── deploy.R
└── promote.sh (optional)
```

- [`deploy.R`](#deployr): our primary model deployment script

- [`promote.sh`](#promotesh): this file is executed before your model is built. It can be used to install low-level system packages such as Linux packages
<hr>

### `deploy.R`
#### Steps
- [Initial Setup](#setup)
- [`model.predict`](#modelpredict)
- [Test Data](#testing)
- [`promote.library`](#promotelibrary)
- [`promote.metadata`](#promotemetadata)
- [`promote.config`](#promoteconfig)
- [`promote.deploy`](#promotedeploy)
<hr>

#### <a name="setup"></a>Initial Setup
Load the `promote` library that was previously installed
```r
library(promote)
```

Import your saved model object
```r
# Previously saved model 'save(my_model, file = "my_model.rda")'
load("my_model.rda")
```
<hr>

#### `model.predict()`
The `model.predict` function is used to define the API endpoint for a model and is executed each time a model is called. **This is the core of the API endpoint**

**Arguments**
- `data`(_Data.Frame_): the data frame generated from the json sent to the deployed model

**Example**
```r
model.predict <- function(data) {
  # generate predictions from the model based on the incoming dataframe
  predict(my_model, data)
}
```
<hr>

#### <a name="testing"></a>Test Data
It is a good practice to test the `model.predict` function as part of the deployment script to make sure it successfully produces an output. Once deployed, the `data` being input into the `model.predict` function will always be in the form of an R [data frame](https://stat.ethz.ch/R-manual/R-devel/library/base/html/data.frame.html). The incoming JSON will be converted to a data frame using the `fromJSON()` method available from either [jsonlite](https://cran.r-project.org/web/packages/jsonlite/jsonlite.pdf) or [rjson](https://cran.r-project.org/web/packages/rjson/rjson.pdf). Which library is used can be configured in the advanced model management section of the Promote App.

**Example**
```r
testdata <- '{"X1":[1,2,3],"X2":[4,5,6]}'
model.predict(data.frame(jsonlite::fromJSON(testdata),stringsAsFactors=TRUE))

```
<hr>

#### `promote.library()`
Tell the Promote servers to install a package required to run `model.predict()`

**Arguments**
- `package`(_string_): the name of the package to install on the Promoter server

**Example**
```r
promote.library("randomforest")
promote.library("plyr")
```
<hr>

#### `promote.metadata()`
Store custom metadata about a model as part of the `model.predict()` when it is sent to the Promote servers. (limited to 6 key-value pairs)

**Arguments**
- `name`(_string_): the name of your metadata (limit 20 characters)
- `value`: a value for your metadata (will be converted to string and limited to 50 characters)

**Example**
```r
promote.metadata("one", 1)
promote.metadata("two", "2")
promote.metadata("list", list(a=1,b=2))
```
<hr>

#### `promote.config()`
To deploy models, add a username, API key, and URL to the `promote.config` variable

**Arguments**
- `username`(_string_): the username used to sign into the Promote app
- `apikey`(_string_): the random API key that is assigned to that username
- `env`(_string_): the URL that can be used to access the Promote app's frontend

**Example**
```r
promote.config <- c(
  username = "username",
  apikey = "apikey",
  env = "http://promote.company.com/"
)
```
<hr>

#### `promote.deploy()`
The deploy function captures `model.predict()` and the `promote.sh` file and sends them to the Promote servers

**Arguments**
- `name`(_string_): the name of the model to deploy to Alteryx Promote
- `confirm`(_boolean_, optional): If `TRUE`, then user will be prompted to confirm deployment

**Example**
```r
promote.deploy(name="IrisClassifier_model", confirm=FALSE)
```
<hr>

### `promote.sh`
The `promote.sh` file can be included in your model directory. It is executed before your model is built and can be used to install low-level system packages such as Linux packages and other dependencies.

**Example**
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
