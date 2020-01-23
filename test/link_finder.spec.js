/* eslint-disable
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const should = require('should');

const linkFinder = require(`${SRC}/link_finder`);

describe('LinkFinder', () => {
  it('should return empty array when response does not contain any links', () => {
    const responseBody = {
      a: 1,
      b: 'hello world',
      c: [1, 2, 3],
    };

    return linkFinder.getLinks(responseBody).should.eql([]);
  });

  it('should return links that are in the root of the body', () => {
    const responseBody = {
      a: 1,
      b: 'hello world',
      c: [1, 2, 3],

      _links: {
        linka: { href: 'a' },
        linkb: { href: 'b' },
        linkc: { href: 'c' },
      },
    };

    return linkFinder.getLinks(responseBody).should.eql(['a', 'b', 'c']);
  });

  it('should return links that are in an array', () => {
    const responseBody = {
      a: 1,
      b: 'hello world',

      c: [
        { _links: { linka: { href: 'a' }, linkb: { href: 'b' }, linkc: { href: 'c' } } },
        { _links: { linka: { href: 'd' }, linkb: { href: 'e' }, linkc: { href: 'f' } } },
      ],
    };

    return linkFinder.getLinks(responseBody).should.eql(['a', 'b', 'c', 'd', 'e', 'f']);
  });

  return it('should return links recursively', () => {
    const responseBody = {
      a: 1,
      b: 'hello world',

      c: [
        { _links: { linka: { href: 'a' }, linkb: { href: 'b' }, linkc: { href: 'c' } } },
        { _links: { linka: { href: 'd' }, linkb: { href: 'e' }, linkc: { href: 'f' } } },
      ],

      d: {
        e: { _links: { linka: { href: 'g' }, linkb: { href: 'h' }, linkc: { href: 'i' } } },

        f: [
          { g: { h: { _links: { linka: { href: 'j' }, linkb: { href: 'k' }, linkc: { href: 'l' } } } } },
        ],
      },
    };

    return linkFinder.getLinks(responseBody).should.eql(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l']);
  });
});
