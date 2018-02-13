library(promote)
library(randomForest)

df <- read.csv("./iris.csv")

# rename columns
names(df) <- c("sepal_length", "sepal_width", "petal_length", "petal_width","class")
head(df)

Rf_fit<-randomForest(formula=class~., data=df)

model.predict <- function(data) {
  pred <- predict(Rf_fit, newdata=data.frame(data))
  result <- data.frame(prediction=pred)
  result 
}

testdata <- df[1,1:4]
model.predict(testdata)

# {"sepal_length":5.1,"sepal_width":3.5,"petal_length":1.4,"petal_width":0.2}

promote.library("randomForest")
promote.library("promote")
promote.config  <- c(
  username="colin",
  apikey="25b58a60-d246-4466-b354-80e20d71225e",
  env="https://promote.c.yhat.com/"
)

promote.deploy("IrisClassifier", confirm = FALSE)

score <-promote.predict("IrisClassifier", testdata)
