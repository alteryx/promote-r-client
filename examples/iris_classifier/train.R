library(promote)
library(randomForest)

df <- read.csv("./iris.csv")

# rename columns
names(df) <- c("sepal_length", "sepal_width", "petal_length", "petal_width","class")
head(df)

Rf_fit <- randomForest(formula = class~., data = df)

model.predict <- function(data) {
  pred <- predict(Rf_fit, newdata = data.frame(data))
  result <- data.frame(prediction = pred)
  result
}

testdata <- df[1, 1:4]
model.predict(testdata)

# create some json for the Promote UI
jsonlite::toJSON(testdata, na='string')
# {"sepal_length":5.1,"sepal_width":3.5,"petal_length":1.4,"petal_width":0.2}

promote.library("randomForest")
promote.library("promote")

promote.config  <- c(
  username = "USERNAME",
  apikey = "APIKEY",
  env = "https://promote_URL.com/"
)

promote.deploy("IrisClassifier", confirm = FALSE)

score <- promote.predict("IrisClassifier", testdata)
