get_month_cost <- function(dat){
    dat$MONTH_COST %>% tail(n=1)
}

get_standard <- function(dat, model){
    dat %>% 
        filter(MODEL == model) %>% 
        select(tomodel) %>% 
        unnest(tomodel) %>% 
        filter( AGE_REG == 0) %>% 
        glimpse()
}




get_preds <- function(dat, mod){
    dat %>% 
        mutate(PRICE = predict(mod, newdata = dat))
}


get_rec <- function(dat){
    recipe(
        data = dat,
        PRICE ~ GEARBOX  + AGE_REG + ENGINE_SIZE  + FUEL_TYPE + AVERAGE_MPG + CO2_EMISSIONS + 
            NFEAT  + SELLER + TOP_SPEED + MILEAGE + DOOR_TYPE +  ANNUAL_TAX + ACCELERATION
    ) %>% 
        step_knnimpute(all_predictors())  %>% 
        step_log( all_outcomes()) %>% 
        #step_BoxCox(all_numeric() , -all_outcomes()) %>% 
        #step_scale(all_numeric(), -all_outcomes()) %>% 
        #step_center(all_numeric(), -all_outcomes()) %>%
        step_zv(all_predictors()) %>% 
        identity() %>% 
        prep(training = dat)
}


get_bake <- function(dat, rec){
    bake(rec, new_data = dat)
}

get_model <- function(dat){
    lm( data = dat , PRICE ~.)
}

get_r2 <- function(mod){
    summary(mod)$adj.r.squared
}


get_to_model_dat <- function(dat){
    median.factor <- function(x, ...){
        x2 <- as.character(x)
        x3 <- table(x2) %>% which.max() %>% names
        factor(x3, levels = levels(x))
    }
    
    new_dat <- tibble(
        SELLER =  factor("TRADE", levels = levels(dat$SELLER)),
        GEARBOX = factor("MANUAL", levels = levels(dat$GEARBOX)),
        AGE_REG = seq(0,12, by = 0.5), 
        MILEAGE  = AGE_REG * 8000,
        BIND = "A"
    )
    
    dat %>% 
        filter( AGE_REG <= 3 ) %>% 
        select(
            NFEAT, ENGINE_SIZE, FUEL_TYPE, TOP_SPEED, DOOR_TYPE,
            ANNUAL_TAX, ACCELERATION, CO2_EMISSIONS, AVERAGE_MPG
        ) %>% 
        summarise_all( median, na.rm = T) %>% 
        mutate(BIND = "A") %>% 
        left_join(new_dat, by = "BIND") %>% 
        select(-BIND)
}


get_summary_inf <- function(dat, yr_start, yr_end){
    dat %>% 
        select(AGE_REG, PRICE) %>% 
        mutate(PRICE = exp(PRICE)) %>% 
        filter( AGE_REG >= yr_start, AGE_REG <= yr_end) %>%
        mutate( START_PRICE = max(PRICE)) %>% 
        mutate(OFFSET = AGE_REG - min(AGE_REG)) %>% 
        mutate(COST = lag(PRICE) - PRICE) %>% 
        mutate( COST = ifelse(row_number() == 1, 0, COST)) %>% 
        mutate(CUMCOST = cumsum(COST)) %>% 
        mutate( YEAR_COST = CUMCOST / OFFSET) %>% 
        mutate(MONTH_COST = YEAR_COST / 12) %>% 
        tail(n=1) %>% 
        select(-OFFSET, -COST)
}












