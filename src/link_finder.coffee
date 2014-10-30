_ = require 'lodash'

linksForKey = (val, key) ->
  if key is '_links'
    _.pluck (_.values val), 'href'
  else if typeof val is 'object'
    _.map val, linksForKey
  else
    []

exports.getLinks = (responseBody) ->
  _.flatten linksForKey(responseBody, '')
