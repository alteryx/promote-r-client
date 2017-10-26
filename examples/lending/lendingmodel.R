library(stringr)
library(plyr)
library(lubridate)
library(randomForest)
library(reshape2)
library(ggplot2)

file <- "./LoanStats3a.csv"
df <- read.csv(file, h=T, stringsAsFactors=F, skip=1)
df.head <- head(df, 100)

head(df)

#annoying column; just get rid of it
df[,'desc'] <- NULL

summary(df)
#almost all NA, so just get rid of it
df[,'mths_since_last_record'] <- NULL

#get rid of fields that are mainly NA
poor_coverage <- sapply(df, function(x) {
  coverage <- 1 - sum(is.na(x)) / length(x)
  coverage < 0.8
})
df <- df[,poor_coverage==FALSE]

##################

bad_indicators <- c("Late (16-30 days)", "Late (31-120 days)", "Default", "Charged Off")

df$is_bad <- ifelse(df$loan_status %in% bad_indicators, 1,
                    ifelse(df$loan_status=="", NA,
                           0))
table(df$loan_status)
table(df$is_bad)

head(df)
df$issue_d <- as.Date(df$issue_d)
df$year_issued <- year(df$issue_d)
df$month_issued <- month(df$issue_d)
df$earliest_cr_line <- as.Date(df$earliest_cr_line)
df$revol_util <- str_replace_all(df$revol_util, "[%]", "")
df$revol_util <- as.numeric(df$revol_util)

outcomes <- ddply(df, .(year_issued, month_issued), function(x) {
  c("percent_bad"=sum(x$is_bad) / nrow(x),
    "n_loans"=nrow(x))
})

plot(outcomes$percent_bad, main="Bad Rate")
outcomes
numeric_cols <- sapply(df, is.numeric)
#turn the data into long format (key->value esque)
df.lng <- melt(df[,numeric_cols], id="is_bad")
head(df.lng)

#plot the distribution for bads and goods for each variable
p <- ggplot(aes(x=value, group=is_bad, colour=factor(is_bad)), data=df.lng)
#quick and dirty way to figure out if you have any good variables
p + geom_density() +
  facet_wrap(~variable, scales="free")

df.term <- subset(df, year_issued < 2012)
df.term$home_ownership <- factor(df.term$home_ownership)
df.term$is_rent <- df.term$home_ownership=="RENT"

idx <- runif(nrow(df.term)) > 0.75
train <- df.term[idx==FALSE,]
test <- df.term[idx==TRUE,]

my.glm <- glm(I(is_bad==FALSE) ~ last_fico_range_low +
                last_fico_range_high +
                is_rent, data=train
              , na.action=na.omit, family=binomial()
)

translateToScore <- function(df) {
  baseline <- 600
  baseline + predict(my.glm, newdata=df) * (40 / log(2))
}

#### Build our model for Promote

library('promote')
promote.library("plyr")

model.predict <- function(df) {
  df$is_rent <- df$home_ownership=="RENT"
  prediction <- predict(my.glm, newdata=df, type="response")
  output <- data.frame(prob_default=prediction)
  output$decline_code <- ifelse(output$prob_default > 0.3,
                                "Credit score too low", "")
  output
}

promote.config <- c(
  username="colin",
  apikey="d325fc5bcb83fc197ee01edb58b4b396",
  env="https://sandbox.c.yhat.com/"
)


promote.deploy("CreditRiskLendingGLM", confirm = FALSE)
