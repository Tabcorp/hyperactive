_ = require 'lodash'

linksForKey = (val, key) ->
  if key is '_links'
    _.map (_.values val), 'href'
  else if typeof val is 'object'
    _.map val, linksForKey
  else
    []

exports.getLinks = (responseBody) ->
  _.flattenDeep linksForKey(responseBody, '')
