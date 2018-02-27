library(datasets)
library(promote)

head(mtcars)
cars <- subset(mtcars, select =-c(vs, am))
rownames(cars) <- NULL

fit <- lm(qsec ~ mpg + cyl + disp + hp + drat + wt + gear + carb, data=cars)

model.predict <- function(data) {
  pred <- predict(fit, newdata=data.frame(data))
  result <- data.frame(prediction=pred)
  result
}

testcase <- data.frame(subset(cars, select = -c(qsec))[1,])
model.predict(testcase)

jsonlite::toJSON(testcase)
# [{"mpg":21,"cyl":6,"disp":160,"hp":110,"drat":3.9,"wt":2.62,"gear":4,"carb":4}] 

promote.config  <- c(
  username = "username",
  apikey = "APIKEY",
  env = "https://PROMOTE_URL.com"
)
promote.deploy ("QuarterMileTime",confirm = FALSE)
