get_seller <- function(js){
    x <- js$initial$seller$isTradeSeller
    assert_that(
        all(!is.na( x))
    )
    x2 <- ifelse(x, "TRADE", "PRIVATE")
    factor( x2, levels = c("TRADE", "PRIVATE"))
}


get_mileage <- function(js){
    x <- js$initial$pageData$tracking$mileage 
    x2 <- ifelse(x %in% c("null", ""), NA_character_, x)
    as.integer(x2)
}


get_doors <- function(js){
    x <- js$initial$pageData$tracking$number_of_doors %>% as.numeric()
    x2 <- vector(length = length(x), mode = "character")
    x2[x >= 4] <- "5 door"
    x2[x <= 3] <- "3 door"
    x2[is.na(x)] <- NA_character_
    factor(x2 , levels = c("3 door", "5 door"))
}

get_fuel_type <- function(js){
    
    fuels <- c(
        'PETROL', 
        'DIESEL', 
        'HYBRID – PETROL/ELECTRIC', 
        'HYBRID – PETROL/ELECTRIC PLUG-IN', 
        'ELECTRIC',
        "UNLISTED"
    )
    
    x <- js$initial$pageData$tracking$fuel_type %>% str_to_upper()
    assert_that(
        all(x %in% fuels),
        msg = "Unknown Fuel Type"
    )
    
    x2 <- case_when(
        x == "HYBRID – PETROL/ELECTRIC" ~ "HYBRID", 
        x == "HYBRID – PETROL/ELECTRIC PLUG-IN" ~ "HYBRID",
        x == "UNLISTED" ~ NA_character_ ,
        TRUE ~ x
    )
    factor(x2, levels = c("PETROL", "DIESEL", "HYBRID", "ELECTRIC"))
}

get_car_make <- function(js){
    x <- js$initial$pageData$tracking$make %>% str_to_upper()
    assert_that(all(!is.na( x)))
    factor(x)
}


get_car_model <- function(js){
    x <- js$initial$pageData$tracking$model %>% str_to_upper()
    x2 <- ifelse(x == "COROLLA", "AURIS", x)
    assert_that(all( !is.na( x2)))
    factor(x2)   
}

get_gearbox <- function(js){
    x <- js$initial$pageData$tracking$gearbox %>% str_to_upper()
    assert_that(all(x %in% c("MANUAL", "AUTOMATIC", "UNLISTED")))
    x[ x == "UNLISTED"] <- NA
    factor(x , levels = c("MANUAL", "AUTOMATIC"))
}





reg_map <- function(x){
    base <- 2000
    if( is.na(x)) return(NA_integer_)
    if( nchar(x) != 2) return(NA_integer_)
    fd <- substr(x , 1, 1) %>% as.numeric()
    sd <- substr(x , 2, 2) %>% as.numeric()
    value <- base + sd
    if( fd %in% c(5,6,7)) value <- value + 0.5
    if (fd %in% c(1,6)) value <- value + 10
    if( fd %in% c(2,7)) value <- value + 20
    if( fd %in% c(3,8)) value <- value + 30
    return(value)
}

get_year <- function(js){
    
    year_reg <- js$initial$vehicle$keyFacts$`manufactured-year`
    year_tracking <- js$initial$pageData$tracking$vehicle_year %>% as.numeric()
    year_vehicle <- js$initial$vehicle$year %>% as.numeric()
    
    regs <- year_reg %>% str_match( "\\((\\d\\d) reg\\)") %>%  .[,2]
    year_reg2 <- map_dbl( regs, reg_map)
    
    year <- coalesce(year_reg2, year_vehicle, year_tracking)
    return(year)
}


#' Function to convert json objects to dataframe
#' @param x single json line
#' @import tibble
#' @import dplyr
#' @import stringr
#' @import purrr
#' @importFrom assertthat assert_that
#' @export
get_raw_data <- function(js){
    dat <- tibble(
        make            = get_car_make(js),
        model           = get_car_model(js),
        price           = js$initial$pageData$tracking$vehicle_price  %>% as.numeric(),
        features        = js$lazy$advert$combinedFeatures,
        seller          = get_seller(js),
        engine_size     = js$initial$pageData$tracking$engine_size %>% as.numeric(),
        top_speed       = js$initial$pageData$tracking$top_speed %>% as.numeric(),
        mileage         = get_mileage(js),
        door_type       = get_doors(js),
        annual_tax      = js$initial$pageData$tracking$annual_tax %>% as.numeric(),
        acceleration    = js$initial$pageData$tracking$acceleration %>% as.numeric() ,
        co2_emissions   = js$initial$pageData$tracking$co2_emissions %>% as.numeric() ,
        average_mpg     = js$initial$pageData$tracking$average_mpg %>% as.numeric(),
        title           = js$initial$advert$title,
        seller_rating   = js$initial$seller$ratingStars %>% as.numeric(),
        link            = js$initial$pageData$canonical ,
        fuel_type       = get_fuel_type(js) ,
        gearbox         = get_gearbox(js),
        year            = get_year(js),
        body_type       = js$initial$pageData$tracking$body_type
    ) %>% 
        rename_with(str_to_upper)
    
    
    remove_dat <- dat %>% 
        group_by(MODEL, FUEL_TYPE) %>% 
        tally() %>% 
        filter(n <= 40)
    
    dat2 <- dat %>% 
        mutate(PRICE = log(PRICE)) %>% 
        select(-FEATURES) %>% 
        anti_join(remove_dat, by = c("MODEL", "FUEL_TYPE")) %>% 
        filter(SELLER == "TRADE")
    
    return(dat2)
}













