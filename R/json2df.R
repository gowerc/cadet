

#' Function to convert json objects to dataframe
#' @param x single json line
#' @import tibble
#' @import dplyr
#' @importFrom assertthat assert_that
#' @export
json2df <- function(js){
    #browser()
    tibble(
        gearbox         = get_gearbox(js) ,
        make            = get_car_make(js),
        model           = get_car_model(js), 
        nfeat           = purrr::map_dbl(js$features, length) , 
        seller          = get_seller(js),
        age_reg         = get_age_reg(js), 
        engine_size     = js$pageData$tracking$engine_size %>% as.numeric(),
        fuel_type       = get_fuel_type(js) ,
        top_speed       = js$pageData$tracking$top_speed %>% as.numeric(),
        mileage         = get_mileage(js),
        door_type       = get_doors(js),
        annual_tax      = js$pageData$tracking$annual_tax %>% as.numeric(),
        acceleration    = js$pageData$tracking$acceleration %>% as.numeric() ,
        co2_emissions   = js$pageData$tracking$co2_emissions %>% as.numeric() ,
        average_mpg     = js$pageData$tracking$average_mpg %>% as.numeric(),
        price           = js$pageData$tracking$vehicle_price  %>% as.numeric(),
        title           = js$advert$title ,
        seller_distance = js$seller$distance %>% as.numeric(),
        seller_rating   = js$seller$ratingStars %>% as.numeric(),
        link            = js$pageData$canonical 
    )
}


get_gearbox <- function(js){
    x <- js$pageData$tracking$gearbox %>% str_to_upper()
    assert_that(all(x %in% c("MANUAL", "AUTOMATIC", "UNLISTED")))
    x[ x == "UNLISTED"] <- NA
    factor(x , levels = c("MANUAL", "AUTOMATIC"))
}

get_mileage <- function(js){
    x <- js$pageData$tracking$mileage 
    x2 <- ifelse(x %in% c("null", ""), NA_character_, x)
    as.integer(x2)
}



get_age_reg <- function(js){
    reg_map <- function(x){
        if( is.na(x)) return(NA_integer_)
        if( nchar(x) != 2) return(NA_integer_)
        fd <- substr(x , 1, 1) %>% as.numeric()
        sd <- substr(x , 2, 2) %>% as.numeric()
        if( fd %in% c(5,6,7)) sd <- sd + 0.5
        if (fd %in% c(0,5)) sd <- sd + 2000
        if (fd %in% c(1,6)) sd <- sd + 2010
        if( fd %in% c(2,7)) sd <- sd + 2020
        return(sd)
    }
    year <- js$pageData$tracking$vehicle_year %>% as.numeric()
    year_reg <- js$vehicle$keyFacts$`manufactured-year` 
    regs <- year_reg %>% str_match( "\\((\\d\\d) reg\\)") %>%  .[,2]
    year_by_reg <- map_dbl( regs, reg_map)
    year_final <- ifelse( !is.na(year_by_reg) , year_by_reg, year)
    2019 - year_final
}

get_doors <- function(js){
    x <- js$pageData$tracking$number_of_doors %>% as.numeric()
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
    
    x <- js$pageData$tracking$fuel_type %>% str_to_upper()
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


get_seller <- function(js){
    x <- js$seller$isTradeSeller
    assert_that(
        all(!is.na( x))
    )
    x2 <- ifelse(x, "TRADE", "PRIVATE")
    factor( x2, levels = c("TRADE", "PRIVATE"))
}


get_car_make <- function(js){
    x <- js$pageData$tracking$make %>% str_to_upper()
    assert_that(all( !is.na( x)))
    factor(x)
}


get_car_model <- function(js){
    x <- js$pageData$tracking$model %>% str_to_upper()
    assert_that(all( !is.na( x)))
    factor(x)   
}


