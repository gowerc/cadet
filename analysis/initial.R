
library(tidyverse)
library(scales)
library(project)
library(recipes)

## Get access to mongo database
mong <- init_mongo()

## Import data as json dataset
js <- mongo2list(mong)

## Extract key values into a tabular df
dat_full <- json2df(js) %>% 
    select_all(str_to_upper)  %>% 
    filter( MILEAGE <= 200000) %>% 
    filter(PRICE <= 60000) 


dat_full %>% 
    group_by(MAKE, MODEL)  %>% 
    tally()

dat_full %>% 
    group_by(MODEL) %>% 
    summarise_all( function(x) sum(is.na(x)))


ggplot(data = dat_full %>% mutate(AGE = floor(AGE_REG)), aes(x = AGE)) + 
    geom_bar(bins = 25, col = "white") + 
    theme_bw() + 
    scale_x_continuous(breaks = pretty_breaks(10))

ggplot(data = dat_full,aes(x = ENGINE_SIZE, y = ACCELERATION)) + 
    geom_point() + 
    theme_bw() + 
    scale_x_continuous(breaks = pretty_breaks(10))

ggplot(data = dat_full,aes(x = ENGINE_SIZE, y = TOP_SPEED)) + 
    geom_point() + 
    theme_bw() + 
    scale_x_continuous(breaks = pretty_breaks(10))


ggplot(dat_full, aes(x = PRICE, y = MILEAGE)) + 
    scale_x_continuous(trans = "log") + 
    geom_point() + 
    theme_bw()

ggplot(dat_full, aes(x = PRICE, y = ACCELERATION)) +
    scale_x_continuous(trans = "log") + 
    geom_point() + 
    theme_bw()

ggplot(dat_full, aes(x = PRICE, y = AGE_REG)) + 
    scale_x_continuous(trans = "log") + 
    geom_point() + 
    theme_bw()

ggplot(dat_full, aes(x = PRICE, y = ANNUAL_TAX)) + 
    scale_x_continuous(trans = "log") + 
    geom_point() + 
    theme_bw()


ggplot(dat, aes(x = PRICE, y = CO2_EMISSIONS)) + 
    scale_x_continuous(trans = "log") + 
    geom_point() + 
    theme_bw()

ggplot(dat_full, aes(x = PRICE, y = AVERAGE_MPG)) + 
    scale_x_continuous(trans = "log") + 
    geom_point() + 
    theme_bw()

ggplot(dat_full, aes(x = DOOR_TYPE, y = PRICE)) +
    scale_y_continuous(trans = "log") + 
    geom_boxplot() + 
    theme_bw()






dat <- dat_full %>% 
    select( -TITLE, -SELLER_DISTANCE , -SELLER_RATING , - LINK, -MAKE) %>% 
    nest(-MODEL) %>% 
    mutate( rec  = map(data, get_rec)) %>% 
    mutate( baked = map2(data, rec, get_bake)) %>% 
    mutate( mod = map(baked, get_model)) %>% 
    mutate( r2 = map_dbl(mod, get_r2)) %>% 
    mutate( tomodel = map(data, get_to_model_dat)) %>% 
    mutate( baked_model = map2(tomodel, rec, get_bake)) %>% 
    mutate( preds = map2( baked_model, mod, get_preds))

dat %>% 
    mutate(S = pmap(list(preds, 2, 8), get_summary_inf)) %>% 
    select(MODEL, S) %>%
    unnest(S)  %>% 
    arrange( MONTH_COST)

get_standard(dat, "FIESTA")
get_standard(dat, "YARIS")
get_standard(dat, "CORSA")
get_standard(dat, "500")



preds <- dat %>% 
    select(MODEL, preds) %>% 
    unnest(preds)

ggplot( data = preds, aes(x = AGE_REG, y = exp(PRICE), col = MODEL, group = MODEL)) +
    geom_point() +
    geom_line() +
    theme_bw() + 
    scale_x_continuous(breaks = pretty_breaks(10)) + 
    scale_y_continuous(breaks = pretty_breaks(10)) + 
    theme(legend.position = "bottom")



dat_full %>% filter(MODEL == "ASTRA")    



