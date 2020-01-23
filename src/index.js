/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const jsmatch = require('js-match');
const crawler = require('./crawler');
const schema  = require('./schema');

exports.crawl = function(config) {
  jsmatch.validate(config, schema);
  return crawler.startCrawl(config, it);
};
