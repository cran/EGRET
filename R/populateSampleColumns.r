#' Populate Sample Columns
#'
#' Creates ConcAve and ConcLow based on Uncen. Removes any samples with NA values in ConcHigh.
#'
#' @param rawData dataframe with dateTime, ConcLow, ConcHigh, Uncen
#' @return Sample2 dataframe with columns: Date, ConcLow, ConcHigh, Uncen, ConcAve, Julian, 
#' Month, Day, DecYear, MonthSeq, waterYear, SinDY, and CosDY (DY = decimal year)
#' @export
#' @examples
#' dateTime <- c('1985-01-01', '1985-01-02', '1985-01-03')
#' ConcLow <- c(1,2,0)
#' ConcHigh <- c(1,2,3)
#' Uncen <- c(1,1,0)
#' dataInput <- data.frame(dateTime, ConcLow, ConcHigh, Uncen, stringsAsFactors=FALSE)
#' Sample <- populateSampleColumns(dataInput)
populateSampleColumns <- function(rawData){  # rawData is a dataframe with dateTime, ConcLow, ConcHigh, Uncen
  Sample <- rawData

  Sample$Date <- rawData$dateTime
  Sample$ConcLow <- rawData$ConcLow
  Sample$ConcHigh <- rawData$ConcHigh
  Sample$Uncen <- rawData$Uncen
  Sample$ConcAve <- ifelse(Sample$ConcHigh == 0, Sample$ConcLow*1.5, (Sample$ConcLow + Sample$ConcHigh)/2)
  Sample$ConcLow <- ifelse((rawData$ConcLow == 0.0 & rawData$Uncen == 0),NA,rawData$ConcLow)
  Sample$ConcHigh <- ifelse((rawData$ConcHigh == 0 & rawData$Uncen == 0), NA, rawData$ConcHigh)
  
  dateFrame <- populateDateColumns(rawData$dateTime)
  Sample <- cbind(Sample, dateFrame[,-1])
  
  Sample$SinDY <- sin(2*pi*Sample$DecYear)
  Sample$CosDY <- cos(2*pi*Sample$DecYear)

  Sample <- Sample[,names(Sample)[!names(Sample) %in% c("code", "value")]]
  return (Sample)  
}
