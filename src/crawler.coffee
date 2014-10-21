_           = require 'lodash'
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

exports.processResponse = (parent, res, templateValues, done) =>
  return done("Bad status #{res.status} for url #{res.url}") if not res.ok
  return done("Not a valid response: #{res.body}") if not validate parent, res
  describe "#{parent}", ->
    _.forEach exports.getLinks(res), (link) ->
      linkFilter.processLink link
      expandedLink = expandUrl(link, templateValues)
      exports.crawl expandedLink, templateValues
  done()

expandUrl = (url, values) ->
  if _.isObject(values) and not _.isEmpty(values)
    templates(url).fillFromObject(values)
  else
    url

validate = (url, res) ->
  return true if not config?.validate?
  return config.validate(url, res.body)

exports.crawl = (url, templateValues) ->
  createIt url, templateValues

exports.startCrawl = (config, it) ->
  exports.reset()
  setIt it if it
  exports.setConfig config
  expandedUrl = expandUrl(config.url, config.templateValues)
  linkFilter.processLink expandedUrl
  exports.crawl expandedUrl, config.templateValues

exports.reset = ->
  linkFilter.reset()
  config = null
  localItFunction = null
