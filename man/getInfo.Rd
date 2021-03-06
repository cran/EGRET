% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/egret_objects.R
\name{getInfo}
\alias{getInfo}
\alias{getInfo.egret}
\alias{getInfo.default}
\title{Get INFO dataframe from EGRET object}
\usage{
getInfo(x, ...)

\method{getInfo}{egret}(x, ...)

\method{getInfo}{default}(x, ...)
}
\arguments{
\item{x}{EGRET object or named list}

\item{\dots}{additional parameters}
}
\value{
INFO dataframe
}
\description{
From a named list or EGRET object, extract the INFO dataframe
}
\examples{
eList <- Choptank_eList
INFO <- getInfo(eList)
}
\seealso{
\code{\link{readNWISDaily}}, \code{\link{readNWISSample}}
}
\keyword{USGS}
\keyword{WRTDS}
\keyword{data}
\keyword{import}
