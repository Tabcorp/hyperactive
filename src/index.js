require('coffee-script/register')

var jsmatch = require('js-match')
var crawler = require('./crawler')
var schema  = require('./schema')

exports.crawl = function(config) {
  jsmatch.validate(config, schema)
  crawler.startCrawl(config, it)
}