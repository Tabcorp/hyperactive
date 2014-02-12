request     = require 'unirest'

exports.request = (url, config) ->
  req = request.get(url)
  req.headers(config.headers) if config?.headers?
  req.auth(config.basicAuth.user, config.basicAuth.pass) if config?.basicAuth?
  req.secureProtocol(config.secureProtocol) if config?.secureProtocol?
  req.strictSSL(config.strictSSL) if config?.strictSSL?
  req

