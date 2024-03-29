% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multiPlotDataOverview.R
\name{multiPlotDataOverview}
\alias{multiPlotDataOverview}
\title{Produces a 4 panel plot that gives an overview of the data set prior to any processing}
\usage{
multiPlotDataOverview(eList, qUnit = 2, cex.main = 1.2,
  randomCensored = FALSE, logScaleConc = TRUE, logScaleQ = TRUE,
  concLab = 1)
}
\arguments{
\item{eList}{named list with at least Daily, Sample, and INFO dataframes}

\item{qUnit}{object of qUnit class \code{\link{printqUnitCheatSheet}}, or 
numeric represented the short code, or character representing the descriptive name.}

\item{cex.main}{magnification to be used for main titles relative to the current setting of cex}

\item{randomCensored}{logical. Show censored values as randomized. Default is FALSE.
If TRUE, makeAugmentedSample must be run first.}

\item{logScaleConc}{logical if TRUE y in concentration graphs plotted in log axis. Default is TRUE.}

\item{logScaleQ}{logical if TRUE y in streamflow graphs plotted in log axis. Default is TRUE.}

\item{concLab}{object of concUnit class, or numeric represented the short code, 
or character representing the descriptive name. By default, this argument sets
concentration labels to use either Concentration or Conc (for tiny plots). Units
are taken from the eList$INFO$param.units. To use any other words than
"Concentration" see \code{vignette(topic = "units", package = "EGRET")}.}
}
\description{
This function produces the 4 plots based only on the data stored in the eList.  
The four plots are 1) log concentration versus log discharge, 2) log concentration versus time
3) a boxplot of log concentration by month, and 
4) a side-by-side boxplot of the sampled discharges and all daily discharges. 
To save space, the graphic is labeled only at the top of the 4 graph display. 

Although there are a lot of optional arguments to this function, most are set to a logical default.
}
\examples{
eList <- Choptank_eList
# Water year:
multiPlotDataOverview(eList, qUnit=1)
# Graphs consisting of Jun-Aug
eList <- setPA(eList, paStart=6,paLong=3)
multiPlotDataOverview(eList, qUnit=1) 

# Custom axes:
eList$INFO$param.units <- "ng"
qConst_precip <- new("qUnit",
                     qShortName = "   mm  ",
                     qUnitFactor = 1,
                     qUnitName = "Millimeter",
                     qUnitExpress = expression(paste("Precipitation in ",mm)),
                     qUnitTiny = expression(paste("Precipitation ", "(", mm, ")")),
                     shortCode = 1,
                     unitUSGS = "Precipitation, in mm",
                     prefix = "Precipitation")

deposition <- new("concUnit",
                  longPrefix = "Deposition",
                  shortPrefix = "Dep")

multiPlotDataOverview(eList, 
                      qUnit = qConst_precip, 
                      concLab = deposition)


}
\seealso{
\code{\link{plotConcQ}}, \code{\link{boxConcMonth}}, 
\code{\link{plotConcTime}}, \code{\link{boxQTwice}}
}
\keyword{graphics}
\keyword{statistics}
\keyword{water-quality}
