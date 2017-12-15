## MOLGENIS R-spss

The MOLGENIS R-spss can import an SPSS-file into MOLGENIS, creating an EntityType and importing data into that EntityType.

## Usage
As an example we will import the sample *experim.sav* into a MOLGENIS instance.

First you have to install the package, so type in the console:
```r
install.packages("molgenisRSpss", dependencies = TRUE)
```

Then you can import this library by executing:
```r
library(molgenisRSpss)
```

This will import the right dependencies when you have installed them in your own environment.

**note**
This package will not work without the molgenisRApi. You have to import it by executing this command:
```r
library(molgenisRApi)
```

First we define the host in which we import the SPSS file(s).
```r
host <- "https://molgenis01.gcc.rug.nl"
```

Now we have to login to a MOLGENIS instance, we use the host variable to specify the host.
```r
token <- molgenis.login(host, "admin", "admin")
```

We use the token and the host to import the experim.sav file into molgenis01.
```r
molgenis.spss.import(host, token, "/samples/experim.sav")
```

You will get the following output:
```
EntityType metadata for: [ experim.sav ] is successfully build (entityType: [ experim ])
The job to import entityType has finished successfully
SPSS-file: [ experim ] is successfully imported as: [ base_experim ]
```

The file is now imported in molgenis01. You can view it by search for *"experim"* in the DataExplorer

## Methods
The SPSS public interface is now described.

### molgenis.spss.import
```r
molgenis.spss.import("host name", "token", "file")
```

You have to login to molgenis first before you can import a file into a molgenis instance.

**Examples**
```r
host <- "https://molgenis01.gcc.rug.nl"
token <- molgenis.login(host, "admin", "admin")
molgenis.spss.import(host, token, "samples/spss-file.sav")
```