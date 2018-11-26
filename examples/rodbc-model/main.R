# load all libraries
library(promote)
library(jsonlite)
library(RODBC)

model.predict <- function(request) {
  string_created<-"Driver={ODBC Driver 17 for SQL Server}; . . ."
  dbhandle <- RODBC::odbcDriverConnect(string_created)
  res <- RODBC::sqlQuery(dbhandle, "select top 10 * from ds_res.DriveSystem_Results")
  message <- paste0("##########################: ", as.character(res$ind_alert_status[1]))
  odbcClose(dbhandle)
  message <- 'executed'
  message
}

# test you model locally
# TESTDATA <- jsonlite::fromJSON('{"name": "colin"}')
# model.predict(TESTDATA)

promote.config  <- c(
  username = "USERNAME",
  apikey = "APIKEY",
  env = "http://promoteurl.com/"
)

#deploy model
promote.deploy("RODBCModel", confirm = FALSE)
