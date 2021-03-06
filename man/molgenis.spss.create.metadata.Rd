% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/molgenisRSpss.R
\name{molgenis.spss.create.metadata}
\alias{molgenis.spss.create.metadata}
\title{Create the SPSS-metadata}
\usage{
molgenis.spss.create.metadata(spss.file.name, spss.data)
}
\arguments{
\item{spss.file.name}{SPSS-file name}

\item{spss.data}{SPSS data matrix}
}
\value{
the entity type name to import
}
\description{
Because the SPSS data has to be stored in a table in MOLGENIS. The table metadata has to be created.
The REST API of MOLGENIS cannot create table-metadata and therefor we create a CSV-file to import in the
importer
}
