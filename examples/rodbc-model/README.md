## RODBC Example

Install an ODBC driver using `promote.sh` and use the RODBC package to make requests. The purpose of this example is to demonstrate how to use a `promote.sh` file to set up Promote for a deployed model. Make sure when deploying that your working directory is the root directory for this example, otherwise the `promote.sh` script will not be bundled and sent to Promote for execution.
 
### Model Response:

If deployed as is, the response of this model will throw the following error. This because the database being connected to doesn't exist.

```
"Error processing prediction from input: Error in model.predict function
Error in RODBC::sqlQuery(dbhandle, \"select top 10 * from ds_res.DriveSystem_Results\"): first argument is not an open RODBC channel
model.predict <- function (request) 
{
    string_created <- \"Driver={ODBC Driver 17 for SQL Server}; . . .\"
    dbhandle <- RODBC::odbcDriverConnect(string_created)
    res <- RODBC::sqlQuery(dbhandle, \"select top 10 * from ds_res.DriveSystem_Results\")
    message <- paste0(\"##########################: \", as.character(res$ind_alert_status[1]))
    odbcClose(dbhandle)
    message <- \"executed\"
    message
}"

```
