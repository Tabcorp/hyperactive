_ = require 'lodash'

processedLinks = {}

exports.reset = ->
  processedLinks = {}

exports.processLink = (link) ->
  processedLinks[link] = link

exports.unprocessedLinks = (links) ->
  _.filter (_.uniq links), (link) ->
    link isnt undefined and processedLinks[link] is undefined

exports.linksToSample = (length, percentage) ->
  Math.ceil((percentage * length) / 100)

exports.filter = (links, samplePercentage) ->
  unprocessedLinks = exports.unprocessedLinks links
  if samplePercentage is 100
    unprocessedLinks
  else
    _.sampleSize unprocessedLinks, exports.linksToSample(unprocessedLinks.length, samplePercentage)
