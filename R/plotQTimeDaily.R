#' Plot of the discharge time series
#'
#' @description
#' Part of flowHistory component.
#' Allows discharge record to only show those discharges above a given threshold
#' 
#'  Although there are a lot of optional arguments to this function, most are set to a logical default.
#'  
#' Data come from named list, which contains a Daily dataframe with the daily flow data,
#' and an INFO dataframe with metadata.
#'
#' @param eList named list with at least the Daily and INFO dataframes
#' @param yearStart numeric indicating the starting year for the graph
#' @param yearEnd numeric indicating the ending year for the graph (should be a time in decimal years that is after the last observations to be plotted)
#' @param qLower numeric specifying the lower bound on discharges that are to be plotted, must be in the units specified by qUnit, default is NA (lower bound is zero)
#' @param qUnit object of qUnit class. \code{\link{printqUnitCheatSheet}}, or numeric represented the short code, or character representing the descriptive name.  Default is qUnit=1 (cubic feet per second)
#' @param tinyPlot logical variable, if TRUE plot is designed to be short and wide, default is FALSE.
#' @param printTitle logical variable if TRUE title is printed, if FALSE title is not printed (this is best for a multi-plot figure)
#' @param lwd line width, a positive number, defaulting to 3
#' @param col specification for the default plotting color
#' @param cex.main magnification to be used for main titles relative to the current setting of cex
#' @param cex.lab magnification to be used for x and y labels relative to the current setting of cex
#' @param customPar logical defaults to FALSE. If TRUE, par() should be set by user before calling this function 
#' (for example, adjusting margins with par(mar=c(5,5,5,5))). If customPar FALSE, EGRET chooses the best margins depending on tinyPlot.
#' @param logScale logical whether or not to use a log scale in the y axis. Default is FALSE.
#' @param prettyDate logical use 'pretty' limits for date axis if TRUE, or force the yearStart/yearEnd as limits if FALSE
#' @param usgsStyle logical option to use USGS style guidelines. Setting this option
#' to TRUE does NOT guarantee USGS compliance. It will only change automatically
#' generated labels. 
#' @param \dots arbitrary graphical parameters that will be passed to genericEGRETDotPlot function (see ?par for options)
#' @keywords graphics streamflow
#' @export
#' @seealso \code{\link{selectDays}}, \code{\link{genericEGRETDotPlot}}
#' @examples
#' eList <- Choptank_eList
#' # Water year:
#' plotQTimeDaily(eList)
#' plotQTimeDaily(eList, yearStart=1990, yearEnd=2000,qLower=1500)
#' plotQTimeDaily(eList, prettyDate=FALSE)
plotQTimeDaily<-function (eList, yearStart=NA, yearEnd=NA, qLower = NA, qUnit = 1, logScale=FALSE,
                          tinyPlot = FALSE, printTitle = TRUE, usgsStyle = FALSE, lwd = 3, col="red", 
                          cex.main = 1.2, cex.lab = 1.2, customPar=FALSE,prettyDate=TRUE,...){
  
  localINFO <- getInfo(eList)
  localDailyOrig <- getDaily(eList)
  
  if(sum(c("paStart","paLong") %in% names(localINFO)) == 2){
    paLong <- localINFO$paLong
    paStart <- localINFO$paStart  
  } else {
    paLong <- 12
    paStart <- 10
  } 

  if(paLong == 12){
    localDaily <- localDailyOrig
  }  else {
    localDailyReturned <- selectDays(localDailyOrig,paLong,paStart)
    localDaily <- merge(localDailyOrig[,-2], localDailyReturned, all.x=TRUE)
    
  }
  
  title2<-if(paLong==12) "" else setSeasonLabelByUser(paStartInput=paStart,paLongInput=paLong)
  #########################################################
  if (is.numeric(qUnit)) {
    qUnit <- qConst[shortCode = qUnit][[1]]
  } else if (is.character(qUnit)) {
    qUnit <- qConst[qUnit][[1]]
  }
  #############################################################
  qFactor<-qUnit@qUnitFactor

  if (tinyPlot){
    yLab <- qUnit@qUnitTiny
  } else {
    yLab <- ifelse(usgsStyle,qUnit@unitUSGS,qUnit@qUnitExpress)
  }
  
  yearStart <- if (is.na(yearStart)) as.integer(min(localDaily$DecYear,na.rm=TRUE)) else yearStart
  yearEnd <- if (is.na(yearEnd)) as.integer(max(localDaily$DecYear,na.rm=TRUE)) else yearEnd
  
  subDaily <- localDaily[localDaily$DecYear >= yearStart & localDaily$DecYear <= yearEnd,]

  xDaily <- subDaily$DecYear
  
  yDaily <- qFactor * subDaily$Q
  if(is.na(qLower)){
    if(logScale){
      yMin <- min(yDaily, na.rm = TRUE)
    } else {
      yMin <- 0
    }
  } else {
    yMin <- qLower
  }

  line2 <- if(is.na(qLower)) "Daily Discharge" else paste("Daily discharge above a threshold of\n",qLower," ",qUnit@qUnitName,sep="")
  line1 <- localINFO$shortName
  
  plotTitle <- if (printTitle) {
    paste(line1, "\n", line2)
  } else {
    ""
  }
  
  if(logScale){
    logText <- "y"
  } else {
    logText <- ""
  }
  
  xInfo <- generalAxis(x=xDaily, minVal=yearStart, maxVal=yearEnd, 
                       tinyPlot=tinyPlot, units=localINFO$param.units, prettyDate=prettyDate)
  yInfo <- generalAxis(x=yDaily, minVal=yMin, maxVal=1.05*max(yDaily), 
                       tinyPlot=tinyPlot,padPercent=0,logScale=logScale, units=localINFO$param.units)

  yInfo$bottom <- max(yInfo$bottom,qLower, na.rm=TRUE)
  yInfo$ticks[1] <- yInfo$bottom

  genericEGRETDotPlot(x=xDaily, y=yDaily, 
                      xlim=c(xInfo$bottom,xInfo$top), ylim=c(yInfo$bottom,yInfo$top),
                      xlab="", ylab=yLab, customPar=customPar,log=logText,
                      xTicks=xInfo$ticks, yTicks=yInfo$ticks, tinyPlot=tinyPlot,
                      plotTitle=plotTitle, cex.main=cex.main,cex.lab=cex.lab,
                      type="l",col=col,lwd=lwd, xDate=TRUE,...
  )
  if (!tinyPlot) mtext(title2,side=3,line=-1.5)

}