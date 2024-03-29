#' Plot of the time series of daily flux estimates and the sample values for the days that were sampled
#'
#' @description
#' This plot is useful for visual examination of the ability of the WRTDS, or other model, to fit the 
#' data, as seen in a time-series perspective. 
#' 
#' Although there are a lot of optional arguments to this function, most are set to a logical default.
#' 
#' Data come from named list, which contains a Sample dataframe with the sample data, 
#' a Daily dataframe with the daily flow data,
#' and an INFO dataframe with metadata. 
#'
#' @param eList named list with at least the Daily, Sample, and INFO dataframes
#' @param yearStart numeric specifying the starting date (expressed as decimal years, for example 1989.0) for the plot
#' @param yearEnd numeric specifying the ending date for the plot 
#' @param tinyPlot logical variable, if TRUE plot is designed to be short and wide, default is FALSE.
#' @param fluxUnit number representing in pre-defined fluxUnit class array. \code{\link{printFluxUnitCheatSheet}}
#' @param fluxMax number specifying the maximum value to be used on the vertical axis, default is NA (which allows it to be set automatically by the data)
#' @param plotGenFlux logical variable. If \code{TRUE}, annual flux points from 
#' \code{WRTDSKalman} output are plotted, if \code{FALSE} WRTDS flux is plotted.
#' @param printTitle logical variable if TRUE title is printed, if FALSE title is not printed (this is best for a multi-plot figure)
#' @param cex numerical value giving the amount by which plotting symbols should be magnified
#' @param cex.main magnification to be used for main titles relative to the current setting of cex
#' @param cex.axis magnification to be used for axis annotation relative to the current setting of cex
#' @param customPar logical defaults to FALSE. If TRUE, par() should be set by user before calling this function 
#' (for example, adjusting margins with par(mar=c(5,5,5,5))). If customPar FALSE, EGRET chooses the best margins depending on tinyPlot.
#' @param col color of points on plot, see ?par 'Color Specification'
#' @param lwd number line width
#' @param randomCensored logical, if TRUE plot a random value for censored data.  Default is FALSE.
#' @param usgsStyle logical option to use USGS style guidelines. Setting this option
#' to TRUE does NOT guarantee USGS compliance. It will only change automatically
#' generated labels. 
#' @param prettyDate logical use 'pretty' limits for date axis if TRUE, or force the yearStart/yearEnd as limits if FALSE
#' @param \dots arbitrary graphical parameters that will be passed to genericEGRETDotPlot function (see ?par for options)
#' @keywords graphics water-quality statistics
#' @export
#' @seealso \code{\link{selectDays}}, \code{\link{genericEGRETDotPlot}}
#' @examples
#' eList <- Choptank_eList
#' # Water year:
#' plotFluxTimeDaily(eList)
#' plotFluxTimeDaily(eList, 2001,2009)
plotFluxTimeDaily <- function (eList, yearStart=NA, yearEnd=NA, 
                             tinyPlot = FALSE, fluxUnit = 3, 
                             fluxMax = NA, randomCensored=FALSE,
                             printTitle = TRUE, 
                             plotGenFlux = TRUE,
                             usgsStyle = FALSE, cex = 0.8, cex.axis = 1.1, cex.main = 1.1, 
                             customPar = FALSE,col = "black",lwd = 1, prettyDate = TRUE,...) {
  
  localINFO <- getInfo(eList)
  localDaily <- getDaily(eList)
  localSample <- getSample(eList)
  
  if(sum(c("paStart","paLong") %in% names(localINFO)) == 2){
    paLong <- localINFO$paLong
    paStart <- localINFO$paStart  
  } else {
    paLong <- 12
    paStart <- 10
  }
  
  if(plotGenFlux){
    if(!all((c("GenFlux","GenConc") %in% names(eList$Daily)))){
      message("plotGenFlux = TRUE requires running WRTDSKalman
              on eList. Switching to WRTDS concentration.")
      plotGenFlux <- FALSE
    }
  }
  
  possibleGoodUnits <- c("mg/l","mg/l as N", "mg/l as NO2", 
                         "mg/l as NO3","mg/l as P","mg/l as PO3","mg/l as PO4","mg/l as CaCO3",
                         "mg/l as Na","mg/l as H","mg/l as S","mg/l NH4" )
  
  allCaps <- toupper(possibleGoodUnits)
  localUnits <- toupper(localINFO$param.units)
  
  if(!(localUnits %in% allCaps)){
    warning("Expected concentration units are mg/l, \nThe INFO dataframe indicates:",localINFO$param.units,
            "\nFlux calculations will be wrong if units are not consistent")
  }
  
  localSample <- if(paLong == 12) localSample else selectDays(localSample,paLong,paStart)
  localDaily <- if(paLong == 12) localDaily else selectDays(localDaily,paLong,paStart)
  
  title2<-if(paLong==12) "" else setSeasonLabelByUser(paStartInput=paStart,paLongInput=paLong)
  
  ################################################################################
  # I plan to make this a method, so we don't have to repeat it in every funciton:
  if (is.numeric(fluxUnit)){
    fluxUnit <- fluxConst[shortCode=fluxUnit][[1]]    
  } else if (is.character(fluxUnit)){
    fluxUnit <- fluxConst[fluxUnit][[1]]
  }
  ################################################################################    
  
  fluxFactor <- fluxUnit@unitFactor*86.40
  
  yearStart <- if (is.na(yearStart)) as.integer(min(localSample$DecYear,na.rm=TRUE)) else yearStart
  yearEnd <- if (is.na(yearEnd)) as.integer(max(localSample$DecYear,na.rm=TRUE)) else yearEnd
  
  subSample <- localSample[localSample$DecYear >= yearStart & localSample$DecYear <= yearEnd,]

  subDaily <- localDaily[localDaily$DecYear >= yearStart & localDaily$DecYear <= yearEnd,]

  xSample <- subSample$DecYear
  xDaily <- subDaily$DecYear

  if(plotGenFlux){
    flux <- subDaily$GenFlux
  } else {
    flux <- subDaily$ConcDay*subDaily$Q*fluxFactor
  }
  
  yLow <- subSample$ConcLow*subSample$Q*fluxFactor
  yHigh <- subSample$ConcHigh*subSample$Q*fluxFactor
  Uncen <- subSample$Uncen

  plotTitle <- if (printTitle) {
    paste(localINFO$shortName, "\n", localINFO$paramShortName, 
          "\n", "Observed and Estimated Flux versus Time")
  } else {
    ""
  }
  
  if (tinyPlot) {
    yLab <- fluxUnit@unitExpressTiny
  } else {
    yLab <- ifelse(usgsStyle, fluxUnit@unitUSGS, fluxUnit@unitExpress)
  }
  ###################################
  
  yBottom <- 0
  
  xInfo <- generalAxis(x = xSample, 
                       minVal = yearStart, maxVal = yearEnd, 
                       tinyPlot = tinyPlot, padPercent = 0,
                       prettyDate = prettyDate)
  
  yCombined <- c(yHigh, flux)
  
  if(!randomCensored){
  
    yInfo <- generalAxis(x = yCombined,
                         minVal = yBottom,
                         maxVal = fluxMax,
                         tinyPlot = tinyPlot,
                         padPercent = 5)
  
    genericEGRETDotPlot(x = xSample, y = yHigh,
                        xlim = c(xInfo$bottom, xInfo$top),
                        ylim = c(yInfo$bottom, yInfo$top),
                        xTicks = xInfo$ticks,
                        yTicks = yInfo$ticks,
                        ylab = yLab,
                        customPar = customPar, cex = cex,
                        plotTitle = plotTitle, 
                        tinyPlot = tinyPlot,cex.axis=cex.axis,
                        cex.main = cex.main,
                        col = col, lwd = lwd, xDate = TRUE,...
      )
    censoredSegments(yBottom = yInfo$bottom,
                     yLow = yLow,
                     yHigh = yHigh,
                     x = xSample,
                     Uncen = Uncen,
                     col = col,
                     lwd = lwd)
  } else {
    if(!("rObserved" %in% names(localSample))){
      eList <- makeAugmentedSample(eList)
      localSample <- eList$Sample
      subSample<-localSample[localSample$DecYear >= yearStart &
                               localSample$DecYear <= yearEnd,]
    }

    yCombined <- c(flux, subDaily$rObserved*subDaily$Q*fluxFactor)
    
    yInfo <- generalAxis(x = yCombined,
                         minVal = yBottom,
                         maxVal = fluxMax,
                         tinyPlot = tinyPlot,
                         padPercent = 5)
    
    genericEGRETDotPlot(x = xSample, y = yHigh,
                        xlim = c(xInfo$bottom, xInfo$top), ylim = c(yInfo$bottom, yInfo$top),
                        xTicks = xInfo$ticks, yTicks = yInfo$ticks,
                        ylab = yLab, customPar = customPar,cex = cex,
                        plotTitle = plotTitle, tinyPlot = tinyPlot,cex.axis=cex.axis,
                        cex.main = cex.main, col = col,lwd = lwd, xDate=TRUE,...
    )
    points(x = xSample[Uncen == 0], 
           y = yHigh[Uncen == 0], 
           pch = 1, cex = cex, col = col)
  }
  
  lines(xDaily, flux, col = col, lwd = lwd)
  
  if (!tinyPlot) mtext(title2,side=3,line=-1.5)

}