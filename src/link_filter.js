/* eslint-disable
    func-names,
    no-return-assign,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('lodash');

let processedLinks = {};

exports.reset = () => processedLinks = {};

exports.processLink = (link) => processedLinks[link] = link;

exports.unprocessedLinks = (links) => _.filter((_.uniq(links)), (link) => (link !== undefined) && (processedLinks[link] === undefined));

exports.linksToSample = (length, percentage) => Math.ceil((percentage * length) / 100);

exports.filter = function (links, samplePercentage) {
  const unprocessedLinks = exports.unprocessedLinks(links);
  if (samplePercentage === 100) {
    return unprocessedLinks;
  }
  return _.sampleSize(unprocessedLinks, exports.linksToSample(unprocessedLinks.length, samplePercentage));
};
