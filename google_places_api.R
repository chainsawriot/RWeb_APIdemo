require(RCurl)
require(rjson)

### Enable the Place API in your google console
### https://code.google.com/apis/console/
### Generate a browser key and don't enter any referrer

googleApiKey <- ""

res <- getForm("https://maps.googleapis.com/maps/api/place/textsearch/json", 
               .params=list(query = "hospital", sensor= "true",
                            type="hospital",location="22.25,114.167", radius="50000", 
                            key=googleApiKey))
res1Json <- fromJSON(res)

res1Json$next_page_token ### request next page with this, max: 60 results
res <- getForm("https://maps.googleapis.com/maps/api/place/textsearch/json", 
               .params=list(query = "hospital", sensor= "true",
                            type="hospital",location="22.25,114.167", radius="50000", 
                            key=googleApiKey, pagetoken=res1Json$next_page_token))
res2Json <- fromJSON(res)
res <- getForm("https://maps.googleapis.com/maps/api/place/textsearch/json", 
               .params=list(query = "hospital", sensor= "true",
                            type="hospital",location="22.25,114.167", radius="50000", 
                            key=googleApiKey, pagetoken=res2Json$next_page_token))
res3Json <- fromJSON(res)

# res3Json$next_page_token is NULL, so there is no more results

res1Json$results[[1]]

# unpack the results
require(plyr)

unpack_res <- function(results) {
  ldply(results, function(location) data.frame(name=location$name, address = location$formatted_address, lat = location$geometry$location$lat, lng = location$geometry$location$lng))
}

all_hospitals <- ldply(list(res1Json$results, res2Json$results, res3Json$results), unpack_res)

### data is not so in the best quality. Some duplicates (e.g. CMC), some are poorly coded (e.g. cannossa),
### some are not strictly hospital. (clinics and MCH) But it works somehow.
