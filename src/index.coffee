jsmatch = require 'js-match'
crawler = require './crawler'
schema  = require './schema'

exports.crawl = (config) ->
  jsmatch.validate config, schema
  crawler.startCrawl config, it
