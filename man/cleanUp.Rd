% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kalman_functions.R
\name{cleanUp}
\alias{cleanUp}
\title{cleanUp eList}
\usage{
cleanUp(eList, seed = NA)
}
\arguments{
\item{eList}{named list with the INFO, Daily, and Sample dataframes and surfaces matrix.}

\item{seed}{integer value. Defaults to NA, which will not change the current seed.
Setting the seed to any given value can be used to create repeatable output.}
}
\value{
eList with duplicated dates in the Sample data frame randomly sampled and censored values are replaced by random values.
}
\description{
Takes an eList as the input. If there are duplicated dates in the Sample data frame, 
will randomly select one value for that date.  If there are censored values
in the data set they will be replaced by random censored values.  If there are no
days with duplicate samples and no censored valued then the eList returned by the function will be identical to the eList that is passed to it.
}
\details{
This function is run before each iteration of generating a random sequence in the 
\code{\link{WRTDSKalman}} function
}
\examples{
eList <- Choptank_eList

eList <- cleanUp(eList)

}
