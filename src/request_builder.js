request     = require 'unirest'

exports.request = (url, config) ->
  req = request.get(url)
  req[key](value) for key, value of config
  req

