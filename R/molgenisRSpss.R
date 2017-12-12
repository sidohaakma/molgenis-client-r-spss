library(foreign)
library(RCurl)
library(rjson)
library(httr)
library(ff)
library(molgenisRApi)

options(scipen=999)
options(tz="Europe/Amsterdam")
Sys.setenv(TZ="Europe/Amsterdam")

molgenis.spss.env <- new.env()

local({
  molgenis.spss.host <- ""
  molgenis.spss.token <- ""
}, molgenis.spss.env)

#' Poll for scheduled job in MOLGENIS
#'
#' You have to check if the status of the job is FINISHED
#' A job can have 3 possible statusses
#' - FINISHED
#' - RUNNING
#' - FAILED
#' 
#' @param job.url job URL which can be used to check the status
#' 
#' @return the job status (FINISHED, RUNNING or FAILED)
#' 
#' @export
molgenis.job.status <- local(function(job.url) {
  url <- paste0(molgenis.spss.host, gsub("\"", "", job.url, fixed=T))
  finished = "false"
  while (finished == "false") {
    response <- httr::GET(url = url)
    response <- httr::content(response, as = "text", encoding = "UTF-8")
    response <- jsonlite::fromJSON(response)
    status <- response$status
    if(status == "FINISHED") {
      finished = "true"
      cat("The job to import entityType has finished successfully\n")
    } else if (status == "FAILED") {
      stop(paste0("Import job has failed. Please check (as administrator): [ ", url, " ]"))
    }
  }
}, molgenis.spss.env)

#' Import the metadata from the SPSS-file
#' 
#' The import opf metadata from the SPSS-file is performed by the MOLGNIS importers.
#' You have to generate a CSV file and then import it with this function.
#' 
#' Default file-name importing for metadata is attributes.csv
#' 
#' @return the importer job url
molgenis.import.csv.metadata <- local(function() {
  import.url <- paste0(molgenis.spss.host, "/plugin/importwizard/importFile")
  response <- httr::POST(url = import.url, 
                         add_headers("x-molgenis-token" = molgenis.spss.token),
                         body = list(action="add", file=upload_file("attributes.csv", "text/csv")))
  response <- httr::content(response, as = "text", encoding = "UTF-8")
  response <- jsonlite::fromJSON(response)
  return(response)
}, molgenis.spss.env)

#' Create the SPSS-metadata
#' 
#' Because the SPSS data has to be stored in a table in MOLGENIS. The table metadata has to be created.
#' The REST API of MOLGENIS cannot create table-metadata and therefor we create a CSV-file to import in the
#' importer
#' 
#' @param file.name SPSS-file name
#' @param data SPSS data matrix
#' 
#' @return the entity type name to import
molgenis.import.csv.create.metadata <- local(function(spss.file.name, spss.data) {
  attributes <- colnames(spss.data)
  entity.type <- tools::file_path_sans_ext(spss.file.name)
  data.type <- "string"
  
  attribute.sheet.columnnames <- c("idAttribute", "name", "entity", "dataType")
  attributes.csv <- matrix(nrow = length(attributes), ncol = 4, dimnames = list(NULL, attribute.sheet.columnnames))
  row.names = NULL
  
  attributes.csv[,1] <- "false"
  attributes.csv[1,1] <- "true"
  attributes.csv[,2] <- attributes
  attributes.csv[,3] <- entity.type
  attributes.csv[,4] <- data.type
  
  write.csv(attributes.csv, "attributes.csv", row.names = F)
  cat(paste0("EntityType metadata for: [ ", spss.file.name, " ] is successfully build (entityType: [ ", entity.type, " ])\n"))
  return(entity.type)
}, molgenis.spss.env)

#' Import the SPSS-file
#'
#' You can import an SPSS file in MOLGENIS via the importer.
#' You have to have a secure connection to import a file into MOLGENIS.
#' The MOLGENIS R API can be used to setup a connection.
#' molgenis.login(#host#, #username#, #password#) can be used.
#'
#' @param molgenis.host molgenis host
#' @param molgenis.token molgenis token
#' @param spss.file SPSS-file to import
#' 
#' @export
molgenis.import.spss <- local(function(molgenis.host, molgenis.token, spss.file) {
  molgenis.spss.host <<- molgenis.host
  molgenis.spss.token <<- molgenis.token
  if(is.null(molgenis.spss.token) || molgenis.spss.token == "") {
    stop(paste0("Please login with the MOLGENIS R API (molgenis.login(#host#, #username#, #password#)\n"))
  }
  spss.data <- read.spss(spss.file, use.value.labels=TRUE, to.data.frame=TRUE)
  entity.type <- molgenis.import.csv.create.metadata(basename(spss.file), spss.data)
  job.url <- molgenis.import.csv.metadata()
  molgenis.job.status(job.url)
  package.entity.type = paste0("base_", entity.type)
  molgenis.addAll(package.entity.type, spss.data)
  cat(paste0("SPSS-file: [ ", entity.type, " ] is successfully imported as: [ ", package.entity.type ," ]\n"))
}, molgenis.spss.env)
