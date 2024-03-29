#' mergeReport 
#'
#' This function does three things.  1) It transfers the daily discharge value 
#' from the Daily data frame to to Sample data frame for those days with samples.
#' 2) It merges the INFO, Daily and Sample data frames to form an eList object, 
#' 3) and it prints out a "report" of basic information about the Daily and 
#' Sample data frames.
#'
#' There must be an INFO and a Daily data frame for this function to work. That would be the case for a study of flow only, with no consideration of water quality.  
#' If water quality is being considered then INFO, Daily, and Sample all need to be provided in the call to this function.
#' 
#' Note that the Sample dataframe in the global environment does 
#' not update with the flow information. 
#'
#' @param INFO dataframe metadata about the Sample and Daily data frames.
#' @param Daily dataframe containing the daily discharge data
#' @param Sample dataframe containing the sample data
#' @param surfaces matrix returned from \code{\link{modelEstimation}}. Default is NA. 
#' @param verbose logical specifying whether or not to display summary information on 
#' the Daily and Sample dataframes.
#' @param interactive logical deprecated. Use 'verbose' instead
#' @keywords data import USGS WRTDS
#' @export
#' @return eList named list with at least INFO, and Daily data frames.  It can also include a Sample data frame.
#' @seealso \code{\link{readNWISDaily}}, \code{\link{readNWISSample}}
#' @examples
#' 
#' siteNumber <- '01491000'
#' pCode <- '00631'
#' \donttest{
#' Daily <- readNWISDaily(siteNumber,'00060', '1984-10-01', '')
#' Sample <- readNWISSample(siteNumber,pCode, '1984-10-01', '')
#' INFO <- readNWISInfo(siteNumber,pCode,interactive=FALSE)
#' eList <- mergeReport(INFO, Daily, Sample)
#' Sample <- eList$Sample
#' plot(eList)
#' 
#' # Create eList with no water quality data:
#' 
#' eList <- mergeReport(INFO, Daily, Sample = NA)
#' plotFour(eList)
#' }
mergeReport <- function(INFO, Daily, Sample = NA, surfaces=NA, verbose = TRUE, interactive=NULL){
  
  if(!is.null(interactive)) {
    warning("The argument 'interactive' is deprecated. Please use 'verbose' instead")
    verbose <- interactive
  }
  
  if (verbose & all(!is.na(Sample))){
    dataOverview(Daily, Sample)  
  }
  
  if(exists("Daily") && !all(is.na(Daily)) && !("Q" %in% names(Daily))){
    message("Please double check that the Daily dataframe is correctly defined.")
  }
  
  
  if(exists("INFO") && !any(c("param.units", "shortName", "paramShortName", "constitAbbrev", "drainSqKm") %in% names(INFO))){
    message("Please double check that the INFO dataframe is correctly defined.")
  }
  
  if(all(!is.na(surfaces))){
    if(!isTRUE(dim(surfaces)[3] == 3 && dim(surfaces)[1] == 14)){
      message("Please double check that the surfaces matrix is correctly defined.")
    }    
  }
  
  if(!all(is.na(Sample))){

    if(!all((c("ConcLow","ConcHigh","Uncen","ConcAve") %in% names(Sample)))){
      message("Please double check that the Sample dataframe is correctly defined.")
    }
    
    Sample <- Sample[order(Sample$Date), ]
    
    if(!all(is.na(Daily))){
      if(all(c("Q","LogQ") %in% names(Sample))){
        if(all(c("yHat","SE","ConcHat") %in% names(Sample))){
          message("Merging new flow data will require modelEstimation to be rerun.")
        }
        
        Sample <- Sample[,!(names(Sample) %in% c("Q","LogQ"))]
        
      }
      Sample <- merge(Daily[,c("Date","Q","LogQ")],Sample,by = "Date",all.y = TRUE)
      if(any(is.na(Sample$Q))){
        message("Some Sample dates do not have corresponding flow data. Not all EGRET functions will work correctly.")
      }
    }    
    
    eList <- as.egret(INFO, Daily, Sample, surfaces)
    
  } else {
    eList <- as.egret(INFO, Daily, Sample = NA, surfaces = NA)
  }
  
  return(eList)
}