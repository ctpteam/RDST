# Test

outcome_dt <- readRDS("./Example/outcome_dt.rds")
treatment_dt <- readRDS("./Example/treatment_dt.rds")
baseline_data <- readRDS("./Example/baseline_data.rds")




## LTMLE - one variable for treatment, here "A". The comparison is for the target parameter "Always treat with A versus never treat with A".

x <- rtmle_init(intervals=4,name_id='ID',name_time='period',name_outcome='outcome',
                name_competing='compete',name_censoring='censor',
                censored_levels=c('1','0'),censored_label="1")
x$data <- list(baseline_data = baseline_data[,.(ID,Age)],
               outcome_data = outcome_dt,
               timevar_data=treatment_dt[1] # just "A"
)
prepare_data(x) <- list()
protocol(x) <- list(name = "A",treatment_variables = "A",intervention = 1)
protocol(x) <- list(name = "not A",treatment_variables = "A",intervention = 0)
target(x) <- list(name = "Risk",strategy = "additive",estimator = "tmle",protocols = c("A","not A"))
x <- run_rtmle(x,time_horizon = 2)
summary(x)


# Once more, but now with a superlearner



x <- rtmle_init(intervals=4,name_id='ID',name_time='period',name_outcome='outcome',
                name_competing='compete',name_censoring='censor',
                censored_levels=c('1','0'),censored_label="1")
x$data <- list(baseline_data = baseline_data[,.(ID,Age)],
               outcome_data = outcome_dt,
               timevar_data=treatment_dt[1] # just "A"
)
prepare_data(x) <- list()
protocol(x) <- list(name = "A",treatment_variables = "A",intervention = 1)
protocol(x) <- list(name = "not A",treatment_variables = "A",intervention = 0)
target(x) <- list(name = "Risk",strategy = "additive",estimator = "tmle",protocols = c("A","not A"))
x <- run_rtmle(x,
               time_horizon = 2,
               refit = TRUE,
               learner = list("learn_ranger_50" = list(num.trees = 20,learner_fun = "learn_ranger"),
                              "learn_glmnet"),folds = 10)
summary(x)

