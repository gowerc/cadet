silver <- list(
    prepare_baker = function(dat){
        
        prep <- recipe(
            data = dat,
            formula = ~ MODEL + MILEAGE + YEAR + TOP_SPEED + DOOR_TYPE + ANNUAL_TAX + 
                CO2_EMISSIONS + ENGINE_SIZE + ACCELERATION + AVERAGE_MPG + FUEL_TYPE +
                GEARBOX
        ) %>% 
            step_modeimpute(all_nominal()) %>% 
            step_meanimpute(all_numeric()) %>% 
            step_zv(all_predictors()) %>% 
            step_center(all_numeric()) %>% 
            step_scale(all_numeric()) %>% 
            prep(training = dat)
        
        function(dat){
            dat2 <- bake(prep, new_data = dat)
            return(dat2)
        }
    },
    
    train_model = function(dat, outcome){
        #browser()
        dat[["OUTCOME"]] <- outcome
        lm( OUTCOME ~ ., data = dat)
    },
    
    predictions = function(mod, dat){
        predict(mod, newdata = dat)
    }
)