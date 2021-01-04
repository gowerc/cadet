

#' Returns pointer to mongo DB
#' @export
get_connection <- function(){
    mongolite::mongo(
        url = "mongodb://root:example@mongo:27017", 
        collection = "all_cars", 
        db = "cars", 
        verbose = FALSE
    )
}


#' @export
clean_db <- function(con){
    x <- con$find( 
        '{ "$or" : [ {"lazy" : { "$eq" : null }}, {"initial" : { "$eq" : null }}]}' ,
        '{"cid" : 1}'
    )
    
    x2 <- readline(sprintf("About to delete %i items, are you sure? [Y/N] > ", length(x$cid)))
    
    if( x2 != "Y"){
        stop("Aborted !!")
    }
    
    con$remove('{"lazy" : { "$eq" : null }}')
    con$remove('{"initial" : { "$eq" : null }}')
}
