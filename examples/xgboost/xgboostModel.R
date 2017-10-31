library(xgboost)
library(promote)
library(jsonlite)

data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test


xb <- xgboost(data = as.matrix(train$data), label = train$label,
                 nrounds = 2, objective = "binary:logistic")


model.predict <- function(matrix) {
  m <- as.matrix(as.data.frame(lapply(matrix, as.numeric)))
  # m <- Matrix(matrix)
  list(predict(xb, newdata=m))
}

testcase <- toJSON(as.matrix(test$data[1:3,]), matrix = "columnmajor")

# test locally
model.predict(fromJSON(testcase))

promote.config  <- c(
  username="colin",
  apikey="d325fc5bcb83fc197ee01edb58b4b396",
  env="https://sandbox.c.yhat.com/"
)

promote.library('xgboost')
promote.library('Matrix')

promote.deploy("xgboosttest",confirm = FALSE)
