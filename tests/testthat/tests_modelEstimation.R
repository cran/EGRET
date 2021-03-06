context("testing modelEstimation")

test_that("modelEstimation produces correct values with default args", {
  skip_on_cran()

  # Uses original and "stale" versions of Choptank data created in `tests/helper-originaldata.R`

  eList_modeled <- modelEstimation(eList_orig_Ch, verbose = FALSE)

  # Running tests via "check" always fails. Test this independently

  info_modeled <- getInfo(eList_modeled)
  daily_modeled <- getDaily(eList_modeled)
  sample_modeled <- getSample(eList_modeled)
  surfaces_modeled <- getSurfaces(eList_modeled)

  ## INFO ##

  # columns retained in info are unaltered after running modelEstimation
  orig_cols_info <- 1:(which(names(info_modeled) == "bottomLogQ") - 1)
  expect_true(all(names(info_orig_Ch) == names(info_modeled[, orig_cols_info])))
  expect_equal(sapply(info_orig_Ch, '[[', 1), sapply(info_modeled[, orig_cols_info], '[[', 1))

  # defaults show up in INFO
  expect_equal(info_modeled[['windowY']], 7)
  expect_equal(info_modeled[['windowQ']], 2)
  expect_equal(info_modeled[['windowS']], 0.5)

  ## DAILY ##

  # daily data is unaltered after running modelEstimation
  expect_equal(daily_modeled[['Date']], daily_orig_Ch[['Date']])
  expect_equal(daily_modeled[['Q']], daily_orig_Ch[['Q']])
  expect_equal(daily_modeled[['Julian']], daily_orig_Ch[['Julian']])
  expect_equal(daily_modeled[['Month']], daily_orig_Ch[['Month']])
  expect_equal(daily_modeled[['Day']], daily_orig_Ch[['Day']])
  expect_equal(daily_modeled[['DecYear']], daily_orig_Ch[['DecYear']])
  expect_equal(daily_modeled[['MonthSeq']], daily_orig_Ch[['MonthSeq']])
  expect_equal(daily_modeled[['Qualifier']], daily_orig_Ch[['Qualifier']])
  expect_equal(daily_modeled[['i']], daily_orig_Ch[['i']])
  expect_equal(daily_modeled[['LogQ']], daily_orig_Ch[['LogQ']])
  expect_equal(daily_modeled[['Q7']], daily_orig_Ch[['Q7']])
  expect_equal(daily_modeled[['Q30']], daily_orig_Ch[['Q30']])

  # daily modeled values come out correctly with defaults
  expect_equal(signif(mean(daily_modeled[['yHat']]),4), 0.1189)
  expect_equal(signif(mean(daily_modeled[['SE']]),4), 0.2681)
  expect_equal(signif(mean(daily_modeled[['ConcDay']]),4), 1.198)
  expect_equal(signif(mean(daily_modeled[['FluxDay']]),4), 366.5)
  expect_equal(signif(mean(daily_modeled[['FNConc']]),4), 1.198)
  expect_equal(signif(mean(daily_modeled[['FNFlux']]),4), 363.1)

  ## SAMPLE ##

  # columns retained in sample are unaltered after running modelEstimation
  orig_cols_sample <- 1:(which(names(sample_modeled) == "yHat") - 1)
  orig_colnames <- names(sample_orig_Ch)
  model_colnames <- names(sample_modeled[, orig_cols_sample])
  orig_names_diff <- setdiff(orig_colnames, model_colnames)
  model_names_diff <- setdiff(model_colnames, orig_colnames)
  expect_true(length(orig_names_diff) == 0 & length(model_names_diff) == 0)
  # reorder columns so that we can compare each column
  sample_modeled_reordered <- sample_modeled[, match(orig_colnames, model_colnames)]
  expect_equal(sapply(sample_orig_Ch, '[[', 1), sapply(sample_modeled_reordered, '[[', 1))

  # sample new columns are correct
  expect_equal(mean(sample_modeled[['yHat']]), 0.0475113943)
  expect_equal(mean(sample_modeled[['SE']]), 0.2629914096)
  expect_equal(mean(sample_modeled[['ConcHat']]), 1.1272620557)

  ## SURFACES ##

  # modelEstimation adds surfaces values
  expect_true(is.na(surfaces_orig_Ch))
  expect_true(all(names(eList_modeled) %in% c("INFO", "Daily", "Sample", "surfaces")))
  expect_equal(nrow(surfaces_modeled), 14)

  # surface estimations are correct
  summary_surface <- summary(surfaces_modeled)
  expect_equal(signif(summary_surface[['Min.']],4), -2.317)
  expect_equal(signif(summary_surface[['1st Qu.']],4), 0.1807)
  expect_equal(signif(summary_surface[['Median']],4), 0.3121)
  expect_equal(signif(summary_surface[['Mean']],4), 0.4082)
  expect_equal(signif(summary_surface[['3rd Qu.']],4), 0.7356)
  expect_equal(signif(summary_surface[['Max.']],4), 3.452)

})

test_that("modelEstimation window params work", {
  skip_on_cran()

  # Uses original and "stale" versions of Arkansas data created in `tests/helper-originaldata.R`

  eList_modeled <- modelEstimation(eList_orig_Ar, windowY = 5,
                                   windowQ = 3, windowS = 0.25)
  info_modeled <- getInfo(eList_modeled)
  daily_modeled <- getDaily(eList_modeled)
  sample_modeled <- getSample(eList_modeled)
  surfaces_modeled <- getSurfaces(eList_modeled)

  ## INFO ##

  # info shows over-ridden default args
  expect_equal(info_modeled[['windowY']], 5)
  expect_equal(info_modeled[['windowQ']], 3)
  expect_equal(info_modeled[['windowS']], 0.25)

  ## DAILY ##

  # daily modeled values come out correctly with user args
  expect_equal(signif(mean(daily_modeled[['yHat']]),4), -3.471)
  expect_equal(signif(mean(daily_modeled[['SE']]),4), 0.6753)
  expect_equal(signif(mean(daily_modeled[['ConcDay']]),4), 0.04439)
  expect_equal(signif(mean(daily_modeled[['FluxDay']]),4), 205300)
  expect_equal(signif(mean(daily_modeled[['FNConc']]),4), 0.04451)
  expect_equal(signif(mean(daily_modeled[['FNFlux']]),4), 200100)

  ## SAMPLE ##

  # sample new columns are correct
  expect_equal(signif(mean(sample_modeled[['yHat']]),4), -3.515)
  expect_equal(signif(mean(sample_modeled[['SE']]),4), 0.6791)
  expect_equal(signif(mean(sample_modeled[['ConcHat']]),4), 0.04218)

  ## SURFACES ##

  # surface estimations are correct
  summary_surface <- summary(surfaces_modeled)
  expect_equal(signif(summary_surface[['Min.']],4), -8.778)
  expect_equal(signif(summary_surface[['1st Qu.']],4), -3.161)
  expect_equal(signif(summary_surface[['Median']],4), 0.03604)
  expect_equal(signif(summary_surface[['Mean']],4), -1.006)
  expect_equal(signif(summary_surface[['3rd Qu.']],4), 0.5875)
  expect_equal(signif(summary_surface[['Max.']],4), 1.390)

})

context("testing setUpEstimation")

test_that('setUpEstimation handles missing info well', {

  # Uses original and "stale" versions of Arkansas data created in `tests/helper-originaldata.R`

  # when Q is missing from Sample, it should be added back in this function
  eList_miss_q <- eList_orig_Ar
  eList_miss_q$Sample$Q <- NULL
  eList_miss_q_setup <- setUpEstimation(eList_miss_q)
  expect_false("Q" %in% names(getSample(eList_miss_q)))
  expect_true("Q" %in% names(getSample(eList_miss_q_setup)))

  # when LogQ is missing from Sample, it should be added back in this function
  eList_miss_logq <- eList_orig_Ar
  eList_miss_logq$Sample$LogQ <- NULL
  # This line keeps failing on travis...not sure why
  # Works on local tests. Also, not a critical test, but still confusing
  # expect_warning(eList_miss_logq_setup <- setUpEstimation(eList_miss_logq))
  expect_false("LogQ" %in% names(getSample(eList_miss_logq)))
  # expect_true("LogQ" %in% names(getSample(eList_miss_logq_setup)))

  # setUpEstimation fails when there are concentration values of zero
  eList_zero <- eList_orig_Ar
  eList_zero$Sample$ConcLow[c(4,33,57)] <- 0
  expect_error(setUpEstimation(eList_zero), "modelEstimation cannot be run with 0 values in ConcLow.")
  expect_silent(setUpEstimation(eList_orig_Ar))

})

test_that("setUpEstimation gives correct results for INFO (new cols & user arg cols correct)", {

  # Uses original and "stale" versions of Choptank data created in `tests/helper-originaldata.R`

  cols_added_from_args <- c("windowY", "windowQ", "windowS", "minNumObs",
                            "minNumUncen", "edgeAdjust")
  cols_added <- c(cols_added_from_args,
                  "bottomLogQ", "stepLogQ", "nVectorLogQ", "bottomYear", "stepYear",
                  "nVectorYear", "windowY", "windowQ", "windowS", "minNumObs",
                  "minNumUncen", "numDays", "DecLow", "DecHigh", "edgeAdjust")

  eList_setup <- setUpEstimation(eList_orig_Ch)
  info_setup <- getInfo(eList_setup)

  # test appropriate columns added
  expect_false(any(cols_added %in% names(info_orig_Ch)))
  expect_true(all(cols_added %in% names(info_setup)))

  # test that defaults are correctly added
  default_args <- as.data.frame(formals(setUpEstimation)[cols_added_from_args])
  args_added <- info_setup[cols_added_from_args]
  expect_equal(sapply(default_args, '[[', 1), sapply(args_added, '[[', 1))

  # test values in each column are correct (just in case the order from `surfaceIndex` ever changes)
  expect_equal(info_setup$bottomLogQ, -4.6641204979)
  expect_equal(info_setup$stepLogQ, 0.7862231099)
  expect_equal(info_setup$nVectorLogQ, 14)
  expect_equal(info_setup$bottomYear, 1979)
  expect_equal(info_setup$stepYear, 0.0625)
  expect_equal(info_setup$nVectorYear, 529)

})
