/* eslint-disable
    func-names,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('lodash');

const linksForKey = function (val, key) {
  if (key === '_links') {
    return _.map((_.values(val)), 'href');
  } if (typeof val === 'object') {
    return _.map(val, linksForKey);
  }
  return [];
};

exports.getLinks = (responseBody) => _.flattenDeep(linksForKey(responseBody, ''));
