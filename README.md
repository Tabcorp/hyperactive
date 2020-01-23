# hyperactive

Small utility used to actively test your API by crawling the hypermedia links

![Logo](https://raw.githubusercontent.com/Tabcorp/hyperactive/master/logo.png)

[![Build Status](https://travis-ci.org/Tabcorp/hyperactive.svg?branch=master)](https://travis-ci.org/Tabcorp/hyperactive)
[![Dependency Status](https://david-dm.org/Tabcorp/hyperactive.png?theme=shields.io)](https://david-dm.org/Tabcorp/hyperactive) [![devDependency Status](https://david-dm.org/Tabcorp/hyperactive/dev-status.png?theme=shields.io)](https://david-dm.org/Tabcorp/hyperactive#info=devDependencies)

[![npm install](https://nodei.co/npm/hyperactive.png?mini=true)](https://nodei.co/npm/hyperactive/) [![Greenkeeper badge](https://badges.greenkeeper.io/Tabcorp/hyperactive.svg)](https://greenkeeper.io/)

## How does it work?

`hyperactive` crawls your API responses, and creates [mocha](https://github.com/visionmedia/mocha) tests for each unique link it finds. Simply pass in some basic config and it will do the rest.

```js
var hyperactive = require('hyperactive');

describe("My API", function() {
  it("should be discoverable", function() {
    hyperactive.crawl({
      url: "http://myApiEndpoint.com/route",
      options: {
        headers: {
          Accept: "application/json"
        }
      }
    });
  })
})
```

Hyperactive will then recursively crawl your API, and make sure it can make a `GET` request to every URL.
Any `4xx` or `5xx` status code while crawling makes the corresponding test fail, and the usual Mocha summary gets printed at the end:

```
1) http://my-api.com/route/that/fails
   Bad status 404

 70 passing (2613ms)
  1 failing
```

*Note:* `hyperactive` needs to run as part of a [mocha](https://github.com/visionmedia/mocha) test suite.
If you want to run it in a different context, just make sure `it` and `describe` are defined in the global scope.

## More options

### - How do I configure extra HTTP options?

For SSL and basicAuth, just add the following to the config:

```js
var hyperactive = require('hyperactive');

describe("My API", function() {
  it("should be discoverable", function() {
    hyperactive.crawl({
      url: "http://myApiEndpoint.com/route",
      options: {
        headers: {
          Accept: "application/json"
        },
        auth : {
          user: "myUsername",
          pass: "myPassword"
        },
        secureProtocol : "SSLv3_client_method",
        strictSSL : false
      }
    });
  })
})
```

*Note:* `hyperactive` uses [unirest](https://github.com/Mashape/unirest-nodejs) to send requests. The `options` hash can contain [any valid Request option](https://github.com/Mashape/unirest-nodejs#requestoptions) from unirest.

### - How does it find hypermedia links?

By default, `hyperactive` looks for links according to the [HAL](http://stateless.co/hal_specification.html) spec:

```json
{
  "resource": {
    "name": "my resource",
    "id": 1,
    "_links": {
      "link1": {
        "href": "http://myApiEndpoint.com/route1"
      },
      "link2": {
        "href": "http://myApiEndpoint.com/route2"
      }
    }
  }
}
```

If you have a different format for links, you can pass your own link finder.
For example, if your API returns the following:

```js
{
  "resource": {
    "name": "my resource",
    "id": 1
  },
  "links": [
    "http://myApiEndpoint.com/route1",
    "http://myApiEndpoint.com/route2"
  ]
}
```

then you can call `hyperactive` with:

``` javascript
function getLinks(responseBody) {
  return responseBody.links;
}

hyperactive.crawl({
  url: "http://myApiEndpoint.com/route",
  options: {
    headers: {
      Accept: "application/json"
    },
  },
  getLinks: getLinks
});
```

The getLinks function receives a [Unirest](https://github.com/Mashape/unirest-nodejs) response
and should return an array of links for that response.
It's up to you to get these links recursively if you have links
nested at several levels inside the response.

### - How do I validate the responses?

By default `hyperactive` just checks that each response returns a `HTTP 200`
(i.e. `res.ok === true`).
You can also pass custom validation function.
For example, if you have the following response:

```json
{
  "success": true,
  "resource": {
    "name": "my resource",
    "id": 1,
    "_links": {
      "link1": {
        "href": "http://myApiEndpoint.com/route1"
      },
      "link2": {
        "href": "http://myApiEndpoint.com/route2"
      }
    }
  }
}
```

Then you can validate it with:

```js
function validate(url, responseBody) {
  if(url.match(/some-url/)) {
    return responseBody.success;
  }
  return true;
}

hyperactive.crawl({
  url: "http://myApiEndpoint.com/route",
  options: {
    headers: {
      Accept: "application/json"
    },
  },
  validate: validate
});
```

### - Will it crawl EVERYTHING?

By default, yes.
If that's taking too long, you can also crawl a percentage of all links:

```js
hyperactive.crawl({
  url: "http://myApiEndpoint.com/route",
  options: {
    headers: {
      Accept: "application/json"
    },
  },
  samplePercentage: 75
});
```
### - Will it crawl link with URI template ?

Yes, you have to specify the values to be used in the URI template
```js
hyperactive.crawl({
  url: "http://myApiEndpoint.com/route",
  templateValues: {
    jurisdiction: 'NSW'
  }
});
```

Even the start url could be a template
```js
hyperactive.crawl({
  url: "http://myApiEndpoint.com/route?jurisdiction={jurisdiction}",
  templateValues: {
    jurisdiction: 'NSW'
  }
});
```

### Can I configure failure thresholds?

By default, `hyperactive` fails any URL that responds with `4xx` or `5xx`. To handle intermittent issues, you can pass a custom `recover` function, which can make a test pass despite the errors. Note that this doesn't handle any errors returned from your custom `validate` function, this is just for recovering from HTTP errors.

For example, you can setup a threshold for `400` errors using:

```js
var failures = 0;

hyperactive.crawl({
  recover: function(res) {
    return (res.statusCode === 400 && ++failure < 10);
  }
});
```

## How can I contribute?

The usual process:

```
npm install
npm test
```

And if everything is passing, submit a pull request :)
