library(xgboost)
library(promote)
library(jsonlite)
library(dotenv)

data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test


xb <- xgboost(data = as.matrix(train$data), label = train$label,
                 nrounds = 2, objective = "binary:logistic")


model.predict <- function(matrix) {
  m <- as.matrix(as.data.frame(lapply(matrix, as.numeric)))
  # m <- Matrix(matrix)
  list(predict(xb, newdata = m))
}

testcase <- jsonlite::toJSON(as.matrix(test$data[1:3,]), matrix = "columnmajor")

# test locally
model.predict(jsonlite::fromJSON(testcase))

# add metadata
promote.metadata("niter",xb$niter)
promote.metadata("best_iter",min(xb$evaluation_log$iter[xb$evaluation_log$train_error==min(xb$evaluation_log$train_error)]))
promote.metadata("best_train_error",min(xb$evaluation_log$train_error))


promote.config  <- c(
  username = Sys.getenv("PROMOTE_USERNAME"),
  apikey = Sys.getenv("PROMOTE_APIKEY"),
  env = Sys.getenv("PROMOTE_URL")
)

promote.library("xgboost")
promote.library("Matrix")

promote.deploy("xgboosttest", confirm = FALSE)
