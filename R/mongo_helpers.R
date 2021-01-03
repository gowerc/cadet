

#' Function to extract mongo data to an R list
#' @param mon Mongo connection
#' @param ... additional arguments passed to mon$export()
#' @export
mongo2list <- function(mong, ... ){
    con <- rawConnection(raw(), 'wb')
    mong$export(con, ...)
    json <- rawToChar(rawConnectionValue(con))
    dat <- jsonlite::stream_in(textConnection(json))
    close.connection(con)
    return(dat)
}

#' Returns pointer to mongo DB
#' @export
init_mongo <- function(){
    mongolite::mongo(url = "mongodb://root:example@mongo:27017", collection = "cars_main", db = "cars", verbose = FALSE)
}
