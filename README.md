# hyperactive

Small utility used to actively test your API by crawling the hypermedia links

## How does it work?

hyperactive works by creating [mocha](https://github.com/visionmedia/mocha) tests for each unique link in your API response

just pass hyperactive some basic config in your mocha test and it will do the rest

## How do I use this in my project?

``` javascript
    hyperactive = require('hyperactive');

    describe("My API", function() {
        it("should be discoverable", function() {
            var config = {
                url: "http://myApiEndpoint.com/route",
                headers: {
                    Accept: "application/json"
                }
            }
            hyperactive.crawl(config);
        })    
    })
```

## What if my API uses SSL and basicAuth?

No problem, just add the following into the config

``` javascript
    hyperactive = require('hyperactive');

    describe("My API", function() {
        it("should be discoverable", function() {
            var config = {
                url: "http://myApiEndpoint.com/route",
                headers: {
                    Accept: "application/json"
                },
                basicAuth : {
                  user: "myUsername",
                  pass: "myPassword"
                },
                secureProtocol : "SSLv3_client_method",
                strictSSL : false
            }
            hyperactive.crawl(config);
        })    
    })
```

## How does hyperactive know where to find my hypermedia links?

hyperactive by default looks for links in the following format
``` javascript
    {
        resource: {
            name: "my resource",
            id: 1,
            _links: {
                link1: {
                    href: "http://myApiEndpoint.com/route1"
                }
                link2: {
                    href: "http://myApiEndpoint.com/route2"
                }
            }
        }
    }
``` 

## But my links don't look like that!

That's fine, hyperactive allows you to pass in your own custom link finding function. 

e.g. if your links look like this
``` javascript
    {
        resource: {
            name: "my resource",
            id: 1 
        }
        links: [
            "http://myApiEndpoint.com/route1", 
            "http://myApiEndpoint.com/route2"
        ]
    }
```
you can call hyperactive with the following configuration and it will find your links

``` javascript
    var config = {
        url: "http://myApiEndpoint.com/route",
        headers: {
            Accept: "application/json"
        },
        getLinks: function(responseBody) {
            return responseBody.links
        }
    }
    hyperactive.crawl(config);
```

The getLinks function will receive a [SuperAgent](https://github.com/visionmedia/superagent) response and return an array of links for that response

## How does hyperactive decide if a response is valid?

By default hyperactive just check the `res.ok` is true of the response

## But I want to do extra validation!

No problem, hyperactive allows you to pass in a validation function
Say you have the following response

``` javascript
    {
        success: true,
        resource: {
            name: "my resource",
            id: 1,
            _links: {
                link1: {
                    href: "http://myApiEndpoint.com/route1"
                }
                link2: {
                    href: "http://myApiEndpoint.com/route2"
                }
            }
        }
    }
```
you can call hyperactive with the following configuration and it will validate that success is `true`

``` javascript
    var config = {
        url: "http://myApiEndpoint.com/route",
        headers: {
            Accept: "application/json"
        },
        validate: function(url, responseBody) {
            if(url.match(/some-url/)) {
                return responseBody.success
            }
            return true
        }
    }
    hyperactive.crawl(config);
```

## But I only want to crawl a subset of my hypermedia links

No problem. Just specify the percentage of links you want to crawl and hyperactive will take care of it for you

``` javascript
    var config = {
        url: "http://myApiEndpoint.com/route",
        headers: {
            Accept: "application/json"
        },
        samplePercentage: 75
    }
    hyperactive.crawl(config);
```

## Testing

```
npm test
```
