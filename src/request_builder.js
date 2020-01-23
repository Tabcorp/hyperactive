/* eslint-disable
    func-names,
    guard-for-in,
    no-restricted-syntax,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const request = require('unirest');

exports.request = function (url, config) {
  const req = request.get(url);
  for (const key in config) { const value = config[key]; req[key](value); }
  return req;
};
