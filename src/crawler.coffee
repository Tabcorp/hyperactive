_           = require 'lodash'
async       = require 'async'
templates   = require 'uri-templates'
linkFinder  = require './link_finder'
linkFilter  = require './link_filter'
build       = require './request_builder'

localItFunction = null

config = null

exports.getLinks = (res) ->
  getLinksFn = if config?.getLinks? then config.getLinks else linkFinder.getLinks
  linkFilter.filter(getLinksFn(res.body), config?.samplePercentage)

exports.setConfig = (userconfig) ->
  config = userconfig

setIt = (it) ->
  localItFunction = it

createIt = (url, templateValues) =>
  localItFunction url, (done) =>
    build.request(url, config.options).end(
      (res) =>
        exports.processResponse(url, res, templateValues, done)
    )

exports.createItWithResult = (url, err) ->
  localItFunction url, (done) ->
    done err

exports.processResponse = (parent, res, templateValues, done) =>
  return done("Bad status #{res.status} for url #{res.url}") if not res.ok
  try
    if not validate parent, res
      return done("Not a valid response: #{res.body}")
  catch err
    return done(err)

  describe "#{parent}", ->
    requests = _.map exports.getLinks(res), (link) ->
      (callback) ->
        linkFilter.processLink link
        expandedLink = expandUrl(link, templateValues)
        build.request(expandedLink, config.options).end (res) =>
          exports.processResponse expandedLink, res, templateValues, (err) ->
            callback null, {err, link: expandedLink}

    async.parallel requests, (err, results) ->
      results.forEach (result) ->
        exports.createItWithResult result.link, result.err
      done()

expandUrl = (url, values) ->
  if _.isObject(values) and not _.isEmpty(values)
    templates(url).fillFromObject(values)
  else
    url

validate = (url, res) ->
  return true if not config?.validate?
  return config.validate(url, res.body)

exports.startCrawl = (config, it) ->
  exports.reset()
  setIt it if it
  exports.setConfig config
  expandedUrl = expandUrl(config.url, config.templateValues)
  linkFilter.processLink expandedUrl
  createIt expandedUrl, config.templateValues

exports.reset = ->
  linkFilter.reset()
  config = null
  localItFunction = null
