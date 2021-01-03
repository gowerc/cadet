#### Great documentation for Mongolite at:
# https://jeroen.github.io/mongolite/


devtools::install()
library(project)

## Get access to mongo database
mong <- init_mongo()

## Import data as json dataset
js <- mongo2list(mong)

## Extract key values into a tabular df
dat_raw <- json2df(js)


###### Querying
#
# Mongo source documentation
# https://docs.mongodb.com/manual/tutorial/project-fields-from-query-results/
#
# mongolite documentation
# https://jeroen.github.io/mongolite/query-data.html#query-syntax
#
# query = filter to reduce return rows
# fields = items to return (note dot notation for sub fields)
mong$find(
    query ='{"model":"CORSA"}', 
    fields = '{ "make": true, "model":true, "seller.isTradeSeller": true}',
    limit = 10,
    sort = '{"seller.isTradeSeller" : 1}'
)


#  Should only sort on indexed columns
# Only _ID is sorted by default
# use mong$index(add = '{"price" : 1}') to add indexes



# Iterating,  returns rows 1 by 1 instead of all at once
it <- mong$iterate(
    query ='{"model":"CORSA"}', 
    fields = '{ "make": true, "model":true, "seller.isTradeSeller": true}',
    limit = 3,
    sort = '{"seller.isTradeSeller" : 1}'
)

it$one()
it$one()
it$one()
it$one()


