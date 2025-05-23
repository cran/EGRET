#' Compress sample data frame
#'
#' Using raw data that has at least dateTime, value, code, populates the measured data portion of the Sample dataframe used in EGRET.
#' ConcLow  = Lower bound for an observed concentration
#' ConcHigh = Upper bound for an observed concentration
#' Uncen    = 1 if uncensored, 0 if censored
#'
#' @param data dataframe contains at least dateTime, code, value, columns in that order. 
#' If there are more than the initial date, code, value...it combines the
#' data is combined as using interval censored concepts. 
#' @param verbose logical specifying whether or not to display progress message
#' @keywords WRTDS flow
#' @return data frame returnDataFrame data frame containing dateTime, ConcHigh, ConcLow, Uncen
#' @export
#' @examples
#' dateTime <- c('1985-01-01', '1985-01-02', '1985-01-03')
#' comment1 <- c("","","")
#' value1 <- c(1,2,3)
#' comment2 <- c("","<","")
#' value2 <- c(2,3,4)
#' comment3 <- c("","","<")
#' value3 <- c(3,4,5)
#' dataInput <- data.frame(dateTime, comment1, value1, 
#'       comment2, value2, 
#'       comment3, value3, stringsAsFactors=FALSE)
#' compressData(dataInput)
compressData <- function(data, verbose = TRUE){  
  

  data <- as.data.frame(data, stringsAsFactors=FALSE)
  numColumns <- ncol(data)
  numDataColumns <- (numColumns-1)/2
  lowConcentration <- rep(0,nrow(data))
  highConcentration <- rep(0,nrow(data))
  uncensored <- rep(0,nrow(data))
  
  i <- 1
  while (i <= numDataColumns) {
    code <- data[2*i]
    value <- data[2*i+1]
    value <- as.numeric(unlist(value))
    value[is.na(value)] <- 0
    returnDataFrame <- as.data.frame(matrix(ncol=2,nrow=nrow(code)))
    colnames(returnDataFrame) <- c('code','value')
    returnDataFrame$code <- code[[1]]
    returnDataFrame$code <- ifelse(is.na(returnDataFrame$code),"",returnDataFrame$code)
    returnDataFrame$value <- value
    concentrationColumns <- populateConcentrations(returnDataFrame)
    lowConcentration <- lowConcentration + concentrationColumns$ConcLow
    highConcentration <- highConcentration + concentrationColumns$ConcHigh
    i <- i + 1
  }
  
  names(data)[1:3] <- c('dateTime', 'code', 'value')
  
  data$dateTime <- as.character(data$dateTime)
  if(dateFormatCheck(data$dateTime)){
    data$dateTime <- as.Date(data$dateTime)  
  } else {
    data$dateTime <- as.Date(data$dateTime,format="%m/%d/%Y")
  }

  
  data$ConcLow <- as.numeric(lowConcentration)
  data$ConcHigh <- as.numeric(highConcentration)
  Uncen1<-ifelse(data$ConcLow==data$ConcHigh,1,0)
  data$Uncen<-ifelse(is.na(data$ConcLow)|is.na(data$ConcHigh),0,Uncen1)
  
  return(data)
}


remove_zeros <- function(data, verbose){
  flaggedData1 <- data[(data$ConcLow == 0 & data$ConcHigh == 0),]
  data <- data[!(data$ConcLow == 0 & data$ConcHigh == 0),]
  
  if (nrow(flaggedData1) > 0){
    WarningMessage <- paste("Deleted", nrow(flaggedData1), "rows of data because concentration was reported as 0.0, the program is unable to interpret that result and is therefore deleting it.")    
    warning(WarningMessage)
    if (verbose){
      cat("Deleted Rows:\n")
      print(flaggedData1)
    }
  }
  return(data)
}
