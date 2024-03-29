#' Reminder to user of flux unit properties  (such as kg/day, tons/year, etc).
#'
#' Cheat sheet to print out pre-defined flux unit properties from fluxUnit class
#' Flux units included:
#' \tabular{lllll}{
#' Number \tab ObjectName \tab shortName \tab unitFactor \tab unitName  \cr
#' 1      \tab POUNDS_DAY \tab lbs/day   \tab 2.204623   \tab pounds/day\cr
#' 2      \tab TONS_DAY   \tab tons/day  \tab 0.001102  \tab tons/day   \cr
#' 3      \tab KG_DAY     \tab kg/day    \tab 1          \tab kg/day    \cr
#' 4      \tab THOUSAND_KG_DAY\tab 10^3 kg/day \tab 0.001 \tab thousands of kg/day\cr
#' 5      \tab TONS_YEAR\tab tons/yr \tab 0.402619 \tab tons/year\cr
#' 6      \tab THOUSAND_TONS_YEAR\tab 10^3 tons/yr \tab 0.000402619 \tab thousands of tons/year \cr
#' 7      \tab MILLION_TONS_YEAR\tab 10^6 tons/yr \tab 4.02619e-07 \tab millions of tons/year\cr
#' 8      \tab THOUSAND_KG_YEAR\tab 10^3 kg/yr \tab 0.36525 \tab thousands of kg/year\cr
#' 9      \tab MILLION_KG_YEAR\tab 10^6 kg/yr \tab 0.00036525 \tab millions of kg/year\cr
#' 10     \tab BILLION_KG_YEAR\tab 10^9 kg/yr \tab 3.6525e-07 \tab billions of kg/year \cr
#' 11     \tab thousandTonsDay \tab 10^3 tons/day \tab 1.102e-06 \tab thousands of tons/day \cr
#' 12     \tab millionKgDay \tab 10^6 kg/day \tab 1e-06 \tab millions of kg/day \cr
#' 13     \tab kgYear \tab kg/year \tab 365.25 \tab kg/year \cr
#' }
#'
#' @keywords graphics water-quality statistics
#' @export
#' @examples
#' printFluxUnitCheatSheet()
printFluxUnitCheatSheet <- function(){
  cat("The following codes apply to the fluxUnit list:\n")
  numObects <- length(fluxConst)
  fluxUnitNameList <- sapply(c(1:numObects), function(x){fluxConst[[x]]@unitName})
  fluxShortCodeList <- sapply(c(1:numObects), function(x){fluxConst[[x]]@shortCode})
  fluxNamesList <- names(fluxConst)
  for (i in 1:numObects){
    cat(fluxShortCodeList[i],"= ", fluxNamesList[i], " (", fluxUnitNameList[i], ")\n")
  }
}

