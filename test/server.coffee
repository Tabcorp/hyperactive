http = require 'http'

exports.createServer = (port) ->

  ROUTE1 = "http://localhost:#{port}/route1"
  ROUTE2 = "http://localhost:#{port}/route2"
  ROUTE3 = "http://localhost:#{port}/route3"

  LINKS_AT_ROOT =
    _links:
      self:
        href: ROUTE1
      route2:
        href: ROUTE2

  LINKS_IN_ARRAY =
    objects: [
      {_links: {route3: { href: ROUTE3}}}
      {_links: {route1: { href: ROUTE1}}}
    ]

  LINKS_IN_OBJECT =
    object:
      name: 'MockObject'
      _links:
        route1:
          href: ROUTE1
        route3:
          href: ROUTE3

  server = http.createServer (req, res) ->
    switch req.url
      when '/route1' then send res, 200, server.LINKS_AT_ROOT
      when '/route2' then send res, 200, server.LINKS_IN_ARRAY
      when '/route3' then send res, 200, server.LINKS_IN_OBJECT
      else send res, 404, 'Not found'

  server.LINKS_AT_ROOT = LINKS_AT_ROOT
  server.LINKS_IN_ARRAY = LINKS_IN_ARRAY
  server.LINKS_IN_OBJECT = LINKS_IN_OBJECT
  server

send = (res, code, data) ->
  res.writeHead code, {'Content-Type': 'application/json'}
  res.end JSON.stringify(data)
