#' @param flux logical if TRUE results are returned in flux, if FALSE concentration. Default is set to FALSE.
#' @export
#' @rdname tableChange
#' @export
#' @return dataframe with Year1, Year2, change[mg/L], slope[mg/L], change[percent], slope[percent] columns. The data in each row is the change or slope calculated from Year1 to Year2
tableChangeSingle<-function(eList, fluxUnit = 9, yearPoints = NA, flux = FALSE) {
  
  localINFO <- getInfo(eList)
  localDaily <- getDaily(eList)
  
  if(!("ConcDay" %in% names(localDaily))){
    stop("This function is only appropriate after running modelEstimation. It requires a ConcDay column in the Daily dataframe.")
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
  
  if(sum(c("paStart","paLong") %in% names(localINFO)) == 2){
    paLong <- localINFO$paLong
    paStart <- localINFO$paStart  
  } else {
    paLong <- 12
    paStart <- 10
  }
  
  localAnnualResults <- setupYears(paStart=paStart,paLong=paLong, localDaily = localDaily)
  
  localAnnualResults <- localAnnualResults[rowSums(is.na(localAnnualResults[,c("Conc","Flux","FNConc","FNFlux")])) != 4,]
   
  ################################################################################
  # I plan to make this a method, so we don't have to repeat it in every funciton:
  if (is.numeric(fluxUnit)){
    fluxUnit <- fluxConst[shortCode=fluxUnit][[1]]    
  } else if (is.character(fluxUnit)){
    fluxUnit <- fluxConst[fluxUnit][[1]]
  }
  ################################################################################ 
  period <- paLong/12
  
  firstYear<-trunc(localAnnualResults$DecYear[1] + period/2)
  numYears<-length(localAnnualResults$DecYear)
  lastYear<-trunc(localAnnualResults$DecYear[numYears] + period/2)
  defaultYearPoints<-seq(lastYear,firstYear,-5)
  numPoints<-length(defaultYearPoints)
  defaultYearPoints[1:numPoints]<-defaultYearPoints[numPoints:1]
  yearPoints<-if(is.na(yearPoints[1])) defaultYearPoints else yearPoints
  numPoints<-length(yearPoints)
  # these last three lines check to make sure that the yearPoints are in the range of the data  
  yearPoints<-if(yearPoints[numPoints]>lastYear) defaultYearPoints else yearPoints
  yearPoints<-if(yearPoints[1]<firstYear) defaultYearPoints else yearPoints
  numPoints<-length(yearPoints)
  fluxFactor<-fluxUnit@unitFactor
  fName<-fluxUnit@shortName
  
  
  cat("\n  ",localINFO$shortName,"\n  ",localINFO$paramShortName)
  periodName<-setSeasonLabel(localAnnualResults = localAnnualResults)
  hasFlex <- c("segmentInfo") %in% names(attributes(eList$INFO))
  if(hasFlex){
    periodName <- paste(periodName,"*")
  }
  
  cat("\n  ",periodName,"\n")
  
  header1<-"\n           Concentration trends\n   time span       change     slope    change     slope\n                     mg/L   mg/L/yr        %       %/yr"
  header2<-"\n\n\n                 Flux Trends\n   time span          change        slope       change        slope"
  
  fNameNoSpace <- gsub(" ","", fName)
  
  if (flux) header1 <- paste(header2, "\n              ",fName,fName,"/yr      %         %/yr", sep="")
  
  blankHolder<-"      ---"
  results<-rep(NA,4)
  indexPoints<-yearPoints-firstYear+1
  numPointsMinusOne<-numPoints-1
  write(header1,file="")
  
  if (flux){
    header <- c("Year1", "Year2", paste("change [", fNameNoSpace, "]", sep=""), paste("slope [", fNameNoSpace, "/yr]", sep=""),"change[percent]", "slope [percent/yr]" )
  } else {
    header <- c("Year1", "Year2", "change[mg/L]","slope[mg/L/yr]","change[%]", "slope [%/yr]")    
  }
  
  resultDF <- as.data.frame(sapply(1:6, function(x) data.frame(x)))
  colnames(resultDF) <- header  
  
  for(iFirst in 1:numPointsMinusOne) {
    xFirst<-indexPoints[iFirst]
    iFirstPlusOne<-iFirst+1
    for(iLast in iFirstPlusOne:numPoints) {
      xLast<-indexPoints[iLast]
      
      if (flux) {
        yLast<-localAnnualResults$FNFlux[indexPoints[iLast]]*fluxFactor
        yFirst<-localAnnualResults$FNFlux[indexPoints[iFirst]]*fluxFactor        
        widthLength <- 12
      } else {
        yLast<-localAnnualResults$FNConc[indexPoints[iLast]]
        yFirst<-localAnnualResults$FNConc[indexPoints[iFirst]]
        widthLength <- 9
      }      
      
      xDif<-xLast - xFirst
      yDif<-yLast - yFirst
      
      
      results[1]<-if(is.na(yDif)) blankHolder else format(yDif,digits=2,width=widthLength)
      results[2]<-if(is.na(yDif)) blankHolder else format(yDif/xDif,digits=2,width=widthLength)
      results[3]<-if(is.na(yDif)) blankHolder else format(100*yDif/yFirst,digits=2,width=widthLength)
      results[4]<-if(is.na(yDif)) blankHolder else format(100*yDif/yFirst/xDif,digits=2,width=widthLength)
      cat("\n",yearPoints[iFirst]," to ",yearPoints[iLast],results)
      resultDF <- rbind(resultDF, c(yearPoints[iFirst], yearPoints[iLast],results))
    }
  }
  cat("\n")
  resultDF <- resultDF[-1,]
  row.names(resultDF) <- NULL
  resultDF <- as.data.frame(lapply(resultDF,as.numeric))
  colnames(resultDF) <- header
  
  invisible(resultDF)
}