/* eslint-disable
    func-names,
    no-return-assign,
    no-shadow,
    no-undef,
    no-use-before-define,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('lodash');
const async = require('async');
const templates = require('uri-templates');

const linkFinder = require('./link_finder');
const linkFilter = require('./link_filter');
const build = require('./request_builder');

const DEFAULT_CONFIG = () => ({
  url: null,
  options: {},
  templateValues: {},
  samplePercentage: 100,
  getLinks: linkFinder.getLinks,
  validate() { return true; },
  recover() { return false; },
});

let localItFunction = null;
let config = DEFAULT_CONFIG();

exports.getLinks = (res) => linkFilter.filter(config.getLinks(res.body), config.samplePercentage);

exports.setConfig = (userconfig) => config = _.extend({}, DEFAULT_CONFIG(), userconfig);

const setIt = (it) => localItFunction = it;

const createIt = (url, templateValues) => localItFunction(url, (done) => build.request(url, config.options).end(
  (res) => exports.processResponse(url, res, templateValues, done),
));

exports.createItWithResult = (url, err) => localItFunction(url, (done) => done(err));

exports.processResponse = (parent, res, templateValues, done) => {
  let err;
  if (!res.ok) {
    if (!config.recover(res)) { err = `Bad status ${res.status} for url ${res.url}`; }
    return done(err);
  }
  try {
    if (!validate(parent, res)) {
      return done(`Not a valid response: ${res.body}`);
    }
  } catch (error) {
    err = error;
    return done(err);
  }

  return describe(`${parent}`, () => {
    const requests = _.map(exports.getLinks(res), (link) => (function (callback) {
      linkFilter.processLink(link);
      const expandedLink = expandUrl(link, templateValues);
      return build.request(expandedLink, config.options).end((res) => exports.processResponse(expandedLink, res, templateValues, (err) => callback(null, { err, link: expandedLink })));
    }));

    return async.parallel(requests, (err, results) => {
      results.forEach((result) => exports.createItWithResult(result.link, result.err));
      return done();
    });
  });
};

const expandUrl = function (url, values) {
  if (_.isObject(values) && !_.isEmpty(values)) {
    return templates(url).fillFromObject(values);
  }
  return url;
};

const validate = (url, res) => config.validate(url, res.body);

exports.startCrawl = function (config, it) {
  exports.reset();
  if (it) { setIt(it); }
  exports.setConfig(config);
  const expandedUrl = expandUrl(config.url, config.templateValues);
  linkFilter.processLink(expandedUrl);
  return createIt(expandedUrl, config.templateValues);
};

exports.reset = function () {
  linkFilter.reset();
  localItFunction = null;
  return config = DEFAULT_CONFIG();
};
