devtools::load_all()
library(ggplot2)


## Get access to mongo database
con <- get_connection()

# clean_db(con)

## Import data as json dataset
js <- con$find('{"initial" : { "$ne" : null }, "lazy" : { "$ne" : null }}')

dat <- get_raw_data(js)

models <- list(
    "gold" = gold,
    "silver" = silver,
    "bronze" = bronze
)

cdat <- cv_compare(
    dat = dat, 
    comparisons = models, 
    outcome = "PRICE", 
    v = 5, 
    repeats = 5,
    strata = "MODEL"
)


ggplot(data = cdat, aes(x = model, y = value)) +
    geom_boxplot() + 
    theme_bw() + 
    xlab("")




