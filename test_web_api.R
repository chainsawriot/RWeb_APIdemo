require(RCurl)
require(rjson)
### Example #1 : getForm without Authorization

### API document: http://www.gov.hk/en/theme/psi/datasets/fundraising.htm

res <- getForm("http://fundraising.one.gov.hk/fundraise_query/webservice/psi/json", .params = list(fromdate = '20130101', todate = '20131231', activity = 'flag', itemperpage = 100))
res.list <- fromJSON(res)
require(plyr)
ldply(res.list$activities, function(x) { c(district = x$districtNameEnglish, org = x$organisationNameEnglish, permit = x$licencePermitTypeEnglish) } )

res.list$totalRecordsSearched

### get page 2

### warning: possibly infinite loop

getAll <- function() {
    resDF <- data.frame()
    currentPage <- 1
    keepGoing <- TRUE
    while (keepGoing) {
        res <- getForm("http://fundraising.one.gov.hk/fundraise_query/webservice/psi/json", .params = list(fromdate = '20130101', todate = '20131231', activity = 'flag', itemperpage = 100, page = as.character(currentPage)))
        res.list <- fromJSON(res)
        resDF <- rbind(resDF, ldply(res.list$activities, function(x) { c(district = x$districtNameEnglish, org = x$organisationNameEnglish, permit = x$licencePermitTypeEnglish) } ))
        currentPage <- currentPage + 1
        if (nrow(resDF) == as.numeric(res.list$totalRecordsSearched)) {
            keepGoing <- FALSE
        }
    }
    return(resDF)
}

finalDF <- getAll()
table(finalDF$district)

## Example #2: get form with Authorization
# Facebook graph API

## to get all the past events of HKRUG

## Facebook Graph API docs: https://developers.facebook.com/docs/graph-api/

## generate a token using graph explorer

token <- ""

ID <- "604041982959300"
u <- paste0("https://graph.facebook.com/", ID, "/events")
res <- getForm(u, .params = list(access_token=token))
ldply(fromJSON(res)$data, function(x) data.frame(x))

## Example #3: post something on FB

ID <- "604041982959300" ### this is the facebook group ID of HKRUG
u <- paste0("https://graph.facebook.com/", ID, "/events")
json <- postForm(u, .params = list(access_token=token, name = "HKRUG[7]", start_time = "2014-01-08T19:30:00+0800")) ### We don't care about the result

## Example #4: Parsing XML
### I hate XML

# API doc: http://www.ncbi.nlm.nih.gov/books/NBK25501/

xmlRes <- getForm("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi", .params = list(db = "pubmed", term = "Freeman+G[au]+Hong+Kong[ad]+2013[dp]"))
require(XML)
doc <- xmlTreeParse(xmlRes)
top <- xmlRoot(doc)
top[[4]] ### IdList
pmid <- xmlSApply(top[[4]], xmlValue)

### get the document summary of all these PMID

xmlRes2 <- getForm("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi", .params = list(db = "pubmed", id = paste0(pmid, collapse=","), retmode = "xml"))
doc2 <- xmlTreeParse(xmlRes2)
top2 <- xmlRoot(doc2)  ### complex structure, search by XPath
nodes <- getNodeSet(top2, "//PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/Title")
sapply(nodes, function(x) xmlSApply(x, xmlValue))

### Bonus: Quick and dirty visualization of these abstracts as a wordcloud

Absnodes <- getNodeSet(top2, "//PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Abstract/AbstractText")
alltext <- paste0(sapply(Absnodes, function(x) xmlSApply(x, xmlValue)), collapse=" ")

### Remember: don't do it like this, it is quick and DDDDDIIIIIIIIIRRRRRRRRRRRTTTTTTTTTTYYYYYYYYYYYYY

require(tm)
DTM <- DocumentTermMatrix(Corpus(VectorSource(alltext)), control=list(removePunctuation = TRUE, stopwords = TRUE, tolower = TRUE))
DTM.df <- data.frame(freq = as.vector(DTM), terms = dimnames(DTM)$Terms)
### Keep terms occur at least thrice
DTM.df <- DTM.df[DTM.df$freq > 2,]
require(wordcloud)
require(RColorBrewer)
pal2 <- brewer.pal(9,"Reds")[1:8]
wordcloud(DTM.df$terms, DTM.df$freq, colors=pal2, random.order=FALSE)
