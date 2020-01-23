/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const http = require('http');

exports.createServer = function(port) {

  const ROUTE1 = `http://localhost:${port}/route1`;
  const ROUTE2 = `http://localhost:${port}/route2`;
  const ROUTE3 = `http://localhost:${port}/route3`;
  const ROUTE4 = `http://localhost:${port}/route4`;

  const LINKS_AT_ROOT = {
    _links: {
      self: {
        href: ROUTE1
      },
      route2: {
        href: ROUTE2
      },
      route4: {
        href: `http://localhost:${port}/{routeFour}`
      }
    }
  };

  const LINKS_IN_ARRAY = {
    objects: [
      {_links: {route3: { href: ROUTE3}}},
      {_links: {route1: { href: ROUTE1}}}
    ]
  };

  const LINKS_IN_OBJECT = {
    object: {
      name: 'MockObject',
      _links: {
        route1: {
          href: ROUTE1
        },
        route3: {
          href: ROUTE3
        }
      }
    }
  };

  const LINKS_WITH_TEMPLATE = {
    _links: {
      self: `http://localhost:${port}/{routeFour}`
    }
  };

  const ERROR_RESPONSE = {
    error: {
      code: "OH_NO",
      message: "Oh no!"
    }
  };

  var server = http.createServer(function(req, res) {
    switch (req.url) {
      case '/route1': return send(res, 200, server.LINKS_AT_ROOT);
      case '/route2': return send(res, 200, server.LINKS_IN_ARRAY);
      case '/route3': return send(res, 200, server.LINKS_IN_OBJECT);
      case '/route4': return send(res, 200, server.LINKS_WITH_TEMPLATE);
      case '/error':  return send(res, 400, server.ERROR_RESPONSE);
      default: return send(res, 404, 'Not found');
    }
  });

  server.LINKS_AT_ROOT = LINKS_AT_ROOT;
  server.LINKS_IN_ARRAY = LINKS_IN_ARRAY;
  server.LINKS_IN_OBJECT = LINKS_IN_OBJECT;
  server.LINKS_WITH_TEMPLATE = LINKS_WITH_TEMPLATE;
  return server;
};

var send = function(res, code, data) {
  res.writeHead(code, {'Content-Type': 'application/json'});
  return res.end(JSON.stringify(data));
};
