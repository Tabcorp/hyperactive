/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const request     = require('unirest');

exports.request = function(url, config) {
  const req = request.get(url);
  for (let key in config) { const value = config[key]; req[key](value); }
  return req;
};

