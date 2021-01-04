
#' @export
model_performance <- function(fold, outcome, model){
    
    train <- rsample::training(fold)
    test <- rsample::testing(fold) 
    
    train_outcome <- train[[outcome]]
    test_outcome <- test[[outcome]]
    
    train[[outcome]] <- NULL
    test[[outcome]] <- NULL
    
    baker <- model$prepare_baker(train)
    
    train_baked <- baker(train)
    test_baked <- baker(test)
    
    assert_that(
        nrow(train_baked) == nrow(train),
        nrow(test_baked) == nrow(test)
    )
    
    mod <- model$train_model(train_baked, train_outcome)
    
    preds <- model$predictions(mod, test_baked)
    
    assert_that(
        length(preds) == length(test_outcome)
    )
    
    yardstick::rmse_vec(
        estimate = preds, 
        truth = test_outcome
    )
}


#' @export
cv_compare <- function(dat, comparisons, outcome, v = 5, repeats = 10, strata = NULL){
    
    cvdat <- rsample::vfold_cv(
        dat,
        v = v, 
        repeats = repeats, 
        strata = strata
    )
    
    for( i in names(comparisons)){
        cvdat[[i]] <- map_dbl(
            cvdat$splits, 
            model_performance, 
            outcome, 
            comparisons[[i]]
        )
    }
    
    results <- cvdat %>% 
        select(names(comparisons)) %>% 
        gather(model, value)
    
    return(results)
}






