
bronze <- list(
    prepare_baker = function(dat){
        
        get_prep <- function(dat){
            recipe(
                data = dat,
                formula = ~ MILEAGE + YEAR + TOP_SPEED + ANNUAL_TAX + DOOR_TYPE +
                    CO2_EMISSIONS + ENGINE_SIZE + ACCELERATION + AVERAGE_MPG + FUEL_TYPE +
                    GEARBOX
            ) %>% 
                step_modeimpute(all_nominal()) %>% 
                step_meanimpute(all_numeric()) %>% 
                step_nzv(all_predictors()) %>% 
                step_center(all_numeric()) %>% 
                step_scale(all_numeric()) %>% 
                prep(training = dat)
        }
        
        gdat <- dat %>% 
            select(-MAKE) %>% 
            nest(data = -MODEL) %>% 
            mutate(prep = map(data, get_prep)) %>% 
            select(-data)
        
        function(dat){
            
            dat2 <- dat %>% 
                select(-MAKE) %>% 
                nest(data = -MODEL) %>% 
                left_join(gdat, by = "MODEL") %>% 
                mutate( ndat = map2(prep, data, bake)) %>% 
                select(MODEL, ndat) %>% 
                unnest(ndat)
                
            return(dat2)
        }
    },
    
    train_model = function(dat, outcome){
        
        get_model <- function(dat){
            
            for(i in names(dat)){
                if(all(is.na(dat[[i]]))) dat[[i]] <- NULL
            }
            
            lm( OUTCOME ~ ., data = dat)
        }
        
        dat %>% 
            mutate(OUTCOME = outcome) %>% 
            nest(data = -MODEL) %>% 
            mutate(MOD = map(data, get_model)) %>% 
            select(MODEL, MOD)
    },
    
    predictions = function(mod, dat){
        
        get_predict <- function(mod, dat){
            predict(mod, newdata = dat)
        }

        dat %>% 
            nest(data = -MODEL) %>% 
            left_join(mod, by = "MODEL") %>% 
            mutate(PREDS = map2(MOD, data, get_predict)) %>% 
            select(PREDS) %>% 
            unnest(PREDS) %>% 
            pull(PREDS)
    }
)




