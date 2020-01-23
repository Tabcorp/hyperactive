/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('lodash');

var linksForKey = function(val, key) {
  if (key === '_links') {
    return _.map((_.values(val)), 'href');
  } else if (typeof val === 'object') {
    return _.map(val, linksForKey);
  } else {
    return [];
  }
};

exports.getLinks = responseBody => _.flattenDeep(linksForKey(responseBody, ''));
