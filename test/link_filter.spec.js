/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _           = require('lodash');
const should      = require('should');
const linkFilter  = require(`${SRC}/link_filter`);

describe('LinkFilter', function() {

  beforeEach(() => linkFilter.reset());

  describe('unprocessedLinks', function() {

    it('should get unique links', () => linkFilter.unprocessedLinks(['a', 'b', 'c', 'b']).should.eql(['a', 'b', 'c']));

    return it('should only get links that are unprocessed', function() {
      linkFilter.processLink('a');
      return linkFilter.unprocessedLinks(['a', 'b', 'c']).should.eql(['b', 'c']);
  });
});

  describe('linksToSample', function() {

    it('should return correct percentage', () => linkFilter.linksToSample(4, 75).should.eql(3));

    it('should always return an int', () => linkFilter.linksToSample(4, 65).should.eql(3));

    return it('should return 1', () => linkFilter.linksToSample(9, 10).should.eql(1));
  });

  return describe('filter', function() {

    it('should return all links if percentage is set to 100', () => linkFilter.filter(['a', 'b', 'c', 'd'], 100).should.eql(['a', 'b', 'c', 'd']));

    return it('should return a percentage of links', () => linkFilter.filter(['a', 'b', 'c', 'd'], 75).length.should.eql(3));
  });
});
