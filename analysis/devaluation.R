devtools::load_all()


## Get access to mongo database
con <- get_connection()

# clean_db(con)

## Import data as json dataset
js <- con$find('{"initial" : { "$ne" : null }, "lazy" : { "$ne" : null }}')

dat <- get_raw_data(js)

hdat <- dat %>% 
    nest(data = c(-MAKE, -MODEL)) %>% 
    mutate( ndat = map(data,get_hypoth_dat)) %>% 
    select(MAKE, MODEL, ndat) %>% 
    unnest(ndat) %>% 
    mutate(FUEL_TYPE = factor("PETROL", levels = levels(FUEL_TYPE)))

hdat2 <- hdat %>% 
    mutate( PRICE = exp(get_predictions(dat, hdat)))

hdat %>% 
    filter(YEAR == 2017) %>% 
    arrange(MAKE, MODEL)

devalulation_summary(hdat2, 2019, 7)
