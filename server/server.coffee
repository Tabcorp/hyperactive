restify = require 'restify'

exports.createServer =  (port) ->
  server = restify.createServer()
  server.use restify.bodyParser {"mapParams": false}
  server.use restify.queryParser {"mapParams": false}

  ROUTE1 = "http://localhost:#{port}/route1"
  ROUTE2 = "http://localhost:#{port}/route2"
  ROUTE3 = "http://localhost:#{port}/route3"

  server.LINKS_AT_ROOT = 
    _links: 
        self: 
          href: ROUTE1
        route2: 
          href: ROUTE2

  server.LINKS_IN_ARRAY = 
    objects: [
      {_links: {route3: { href: ROUTE3}}}
      {_links: {route1: { href: ROUTE1}}}
    ]

  server.LINKS_IN_OBJECT = 
    object:
      name: "MockObject"
      _links: 
        route1: 
          href: ROUTE1
        route3: 
          href: ROUTE3

  server.get '/route1', (req, res, next) ->
    willReturn server.LINKS_AT_ROOT, res, next

  server.get '/route2', (req, res, next) ->
    willReturn server.LINKS_IN_ARRAY, res, next

  server.get '/route3', (req, res, next) ->
    willReturn server.LINKS_IN_OBJECT, res, next

  server

willReturn = (data, res, next) ->
  res.send 200, data
  next()
