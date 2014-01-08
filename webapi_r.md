Web API and R
========================================================

## Web API: preliminaries

Programmatic interface to a defined request-response message system which is exposed via the web.

(WTF!)

## Example

[Data.One: Approved Charitable Fund-raising Activities](http://www.gov.hk/en/theme/psi/datasets/fundraising.htm)

* The web
* Programmatic
* Request-response
* Defined message system

## Protocol

* **REST** - Using Standard HTTP(S) methods
* SOAP
* XML-PRC

## Typical HTTP Methods and response

Method

* **GET**
* **POST**
* PUT
* DELETE

Response

* JSON
* XML

(WTF!)

## Example: read the API document

* [Twitter REST 1.1 API documentation](https://dev.twitter.com/docs/api/1.1)
* [Sina Weibo API2 documentation](http://open.weibo.com/wiki/%E5%BE%AE%E5%8D%9AAPI)

## Make a request

* Using browser (for GET)
* Using [cURL](http://en.wikipedia.org/wiki/CURL) (for GET and POST)

Demo of curl command

## Authorization

* Rate limit
* Usually OAuth2 to obtain access token

## JSON / XML parsing: R's List operations


```r
library(plyr)
example <- list(a = c(1, 2, 3), b = c(9, 10, 11))
example
```

```
## $a
## [1] 1 2 3
## 
## $b
## [1]  9 10 11
```

```r
example$a
```

```
## [1] 1 2 3
```

```r
ldply(example, function(x) x)
```

```
##   .id V1 V2 V3
## 1   a  1  2  3
## 2   b  9 10 11
```

# The real deal

Web API & R

## tools

* Make the request
  * RCurl
* Parse the response
  * rjson
  * XML

## installation #1

* Linux: External dependencies (assuming deb-based):
  * libcurl4-openssl-dev
  * libxml2-dev


```{bash}
locate libcurl | grep libcurl.so
locate libxml | grep libxml2.so
```

## installation #2

```
install.packages(c("RCurl", "XML", "rjson"))
```

## Some examples

Go through some code together

## Advice

* httr package
* [Web Technologies Task View: Are there wheels not to reinvent](http://cran.r-project.org/web/views/WebTechnologies.html)
