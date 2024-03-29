#' Graph of observed versus estimated flux
#'
#' @description
#' Data come from named list, which contains a Sample dataframe with the sample data, 
#' and an INFO dataframe with metadata. 
#' 
#' Although there are a lot of optional arguments to this function, most are set to a logical default. 
#'
#' @param eList named list with at least the Sample and INFO dataframes
#' @param fluxUnit number representing entry in pre-defined fluxUnit class array. \code{\link{printFluxUnitCheatSheet}}
#' @param fluxMax number specifying the maximum value to be used on the vertical axis, default is NA (which allows it to be set automatically by the data)
#' @param printTitle logical variable if TRUE title is printed, if FALSE not printed (this is best for a multi-plot figure)
#' @param oneToOneLine inserts 1:1 line
#' @param tinyPlot logical variable if TRUE plot is designed to be small, if FALSE it is designed for page size, default is FALSE (not fully implemented yet)
#' @param logScale logical if TRUE x and y plotted in log axis
#' @param cex numerical value giving the amount by which plotting symbols should be magnified
#' @param cex.main magnification to be used for main titles relative to the current setting of cex
#' @param cex.axis magnification to be used for axis annotation relative to the current setting of cex
#' @param customPar logical defaults to FALSE. If TRUE, par() should be set by user before calling this function 
#' (for example, adjusting margins with par(mar=c(5,5,5,5))). If customPar FALSE, EGRET chooses the best margins depending on tinyPlot.
#' @param col color of points on plot, see ?par 'Color Specification'
#' @param lwd number line width
#' @param usgsStyle logical option to use USGS style guidelines. Setting this option
#' to TRUE does NOT guarantee USGS compliance. It will only change automatically
#' generated labels. 
#' @param randomCensored logical. Show censored values as randomized.
#' @param \dots arbitrary graphical parameters that will be passed to genericEGRETDotPlot function (see ?par for options)
#' @keywords graphics water-quality statistics
#' @export
#' @seealso \code{\link{selectDays}}, \code{\link{genericEGRETDotPlot}}
#' @examples
#' eList <- Choptank_eList
#' # Water year:
#' plotFluxPred(eList)
#' plotFluxPred(eList, fluxUnit = 'poundsDay')
#' plotFluxPred(eList, logScale=TRUE)
#' # Graphs consisting of Jun-Aug
#' eList <- setPA(eList, paStart=6,paLong=3)
#' plotFluxPred(eList)
plotFluxPred<-function(eList, fluxUnit = 3, fluxMax = NA, 
                       printTitle = TRUE, oneToOneLine=TRUE, customPar=FALSE,col="black", lwd=1,
                       cex=0.8, cex.axis=1.1,cex.main=1.1,
                       tinyPlot=FALSE, usgsStyle=FALSE,logScale=FALSE,randomCensored = FALSE,...){
  # this function shows observed versus estimated flux
  # estimated flux on the x-axis (these include the bias correction), 
  # observed flux on y-axis 
  # these estimates are from a jack-knife, "leave-one-out", cross validation application of WRTDS
  
  localINFO <- getInfo(eList)
  localSample <- getSample(eList)
  
  if(!all((c("SE","yHat") %in% names(eList$Sample)))){
    stop("This function requires running modelEstimation on eList")
  }
  
  if(sum(c("paStart","paLong") %in% names(localINFO)) == 2){
    paLong <- localINFO$paLong
    paStart <- localINFO$paStart  
  } else {
    paLong <- 12
    paStart <- 10
  }
  
  possibleGoodUnits <- c("mg/l","mg/l as N", "mg/l as NO2", "mg/L",
                         "mg/l as NO3","mg/l as P","mg/l as PO3","mg/l as PO4","mg/l as CaCO3",
                         "mg/l as Na","mg/l as H","mg/l as S","mg/l NH4" )
  
  allCaps <- toupper(possibleGoodUnits)
  localUnits <- toupper(localINFO$param.units)
  
  if(!(localUnits %in% allCaps)){
    warning("Expected concentration units are mg/l, \nThe INFO dataframe indicates:",localINFO$param.units,
            "\nFlux calculations will be wrong if units are not consistent")
  }
  
  localSample <- if(paLong == 12) localSample else selectDays(localSample,paLong,paStart)
  
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
  x<-localSample$ConcHat*localSample$Q*fluxFactor

  Uncen<-localSample$Uncen

  if (tinyPlot) {
    xLab <- fluxUnit@unitEstimateTiny
    yLab <- substitute(a ~ b, list(a="Obs.",b= fluxUnit@unitExpressTiny[[1]]))
  } else {
    if(usgsStyle){
      xLab <- paste("Estimated", tolower(fluxUnit@unitUSGS))
      yLab <- paste("Observed", tolower(fluxUnit@unitUSGS))
    } else {
      xLab <- substitute(a ~ b, list(a = "Estimated" ,
                                     b = fluxUnit@unitEstimate[[1]]))
      yLab <- substitute(a ~ b, list(a ="Observed",
                                     b = fluxUnit@unitEstimate[[1]]))
    }
  }
  
  if(logScale){
    logText <- "xy"
    minX <- NA
    minY <- NA
  } else {
    logText <- ""
    minX <- 0
    minY <- 0
  }
  
  plotTitle<-if(printTitle) paste(localINFO$shortName,"\n",localINFO$paramShortName,"\n","Observed vs Estimated Flux") else ""

  xInfo <- generalAxis(x=x, minVal=minX, maxVal=NA, logScale=logScale, tinyPlot=tinyPlot,padPercent=5)  

  if(!randomCensored){
    yLow<-localSample$ConcLow*localSample$Q*fluxFactor
    yHigh<-localSample$ConcHigh*localSample$Q*fluxFactor
    
    yInfo <- generalAxis(x=yHigh, minVal=minY, maxVal=fluxMax, logScale=logScale, tinyPlot=tinyPlot,padPercent=5)
    
    genericEGRETDotPlot(x=x, y=yHigh,
                        xTicks=xInfo$ticks, yTicks=yInfo$ticks,
                        xlim=c(xInfo$bottom,xInfo$top), ylim=c(yInfo$bottom,yInfo$top),
                        xlab=xLab, ylab=yLab,log=logText, customPar=customPar,
                        plotTitle=plotTitle,oneToOneLine=oneToOneLine, cex=cex,col=col,
                        tinyPlot=tinyPlot,cex.axis=cex.axis,cex.main=cex.main,...
    )
    
    censoredSegments(yBottom=yInfo$bottom, yLow=yLow, yHigh=yHigh, x=x, Uncen=Uncen,col=col,lwd=lwd)
  } else {
    if(!("rObserved" %in% names(localSample))){
      eList <- makeAugmentedSample(eList)
      localSample <- eList$Sample
    }
    yLow<-localSample$rObserved*localSample$Q*fluxFactor
    yHigh<-localSample$rObserved*localSample$Q*fluxFactor
    
    yInfo <- generalAxis(x=yHigh, minVal=minY, maxVal=fluxMax, logScale=logScale, tinyPlot=tinyPlot,padPercent=5)
    
    genericEGRETDotPlot(x=x[Uncen == 1], y=yHigh[Uncen == 1],
                        xTicks=xInfo$ticks, yTicks=yInfo$ticks,
                        xlim=c(xInfo$bottom,xInfo$top), ylim=c(yInfo$bottom,yInfo$top),
                        xlab=xLab, ylab=yLab,log=logText, customPar=customPar,
                        plotTitle=plotTitle,oneToOneLine=oneToOneLine, cex=cex,col=col,
                        tinyPlot=tinyPlot,cex.axis=cex.axis,cex.main=cex.main,...
    )
    points(x=x[Uncen == 0], y=yHigh[Uncen == 0], pch=1,cex=cex,col=col)
  }
  if (!tinyPlot) mtext(title2,side=3,line=-1.5)

}