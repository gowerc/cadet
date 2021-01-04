
#' @import lubridate
#' @export
get_hypoth_dat <- function(dat){
    median.factor <- function(x, ...){
        x2 <- as.character(x)
        x3 <- table(x2) %>% which.max() %>% names
        factor(x3, levels = levels(x))
    }
    
    new_dat <- tibble(
        SELLER =  factor("TRADE", levels = levels(dat$SELLER)),
        GEARBOX = factor("MANUAL", levels = levels(dat$GEARBOX)),
        YEAR = seq(2005, year(today()), by = 0.5), 
        AGE = (year(today()) - YEAR) ,
        MILEAGE  = AGE  * 8000,
        BIND = "A"
    )
    
    dat %>% 
        mutate(AGE = (year(today()) - YEAR)) %>% 
        filter( AGE <= 4 ) %>% 
        select(
            ENGINE_SIZE, FUEL_TYPE, TOP_SPEED, DOOR_TYPE,
            ANNUAL_TAX, ACCELERATION, CO2_EMISSIONS, AVERAGE_MPG
        ) %>% 
        summarise_all( median, na.rm = T) %>% 
        mutate(BIND = "A") %>% 
        left_join(new_dat, by = "BIND") %>% 
        select(-BIND) 
}

#' @export
get_predictions <- function(train, test){

    train_outcome <- train[["PRICE"]]
    
    train[["PRICE"]] <- NULL
    
    baker <- gold$prepare_baker(train)
    
    train_baked <- baker(train)
    test_baked <- baker(test)
    
    assert_that(
        nrow(train_baked) == nrow(train),
        nrow(test_baked) == nrow(test)
    )
    
    mod <- gold$train_model(train_baked, train_outcome)
    
    preds <- gold$predictions(mod, test_baked)
    
    return(preds)
}




#' @export
devalulation_summary <- function(hdat, year, hold){
    hdat %>% 
        filter(YEAR <= year, YEAR >= year - hold) %>% 
        group_by(MAKE, MODEL) %>% 
        summarise(
            YEAR = max(YEAR),
            HOLD = hold,
            START_PRICE = max(PRICE),
            END_PRICE = min(PRICE),
            COST = START_PRICE - END_PRICE,
            COST_MONTH = COST / (hold * 12)
        ) %>% 
        arrange(COST_MONTH) %>% 
        ungroup()
}





