/* eslint-disable
    camelcase,
    func-names,
    no-unused-vars,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('lodash');
const should = require('should');
const sinon = require('sinon');

const crawler = require(`${SRC}/crawler`);
const linkFinder = require(`${SRC}/link_finder`);
const server = require('./server');

const assertCalledWithFirstArg = function (stub, callIndex, expected) {
  const actual = stub.args[callIndex][0];
  return actual.should.eql(expected);
};

const assertCalledWith = function (stub, callIndex, expected) {
  const actual = stub.args[callIndex];
  return actual.should.eql(expected);
};

const OK_RES_BODY = { totallyValid: 'res' };
const OK_RES = { body: OK_RES_BODY, ok: true };
const BAD_RES = { ok: false, status: 503, body: 'Server down' };

describe('Crawler with server', () => {
  let stubbedIt = (function () {});
  let stubbedDone = (function () {});
  let dummyServer = null;

  const PORT = 6000;
  const config = {
    url: `http://localhost:${PORT}/{routeOne}`,

    options: {
      headers: {
        Accept: 'application/json',
      },
    },

    templateValues: {
      routeOne: 'route1',
      routeFour: 'route4',
    },
  };

  const err_config = {
    url: `http://localhost:${PORT}/{routeOne}`,

    options: {
      headers: {
        Accept: 'application/json',
      },
    },

    templateValues: {
      routeOne: 'error',
    },
  };

  before((done) => {
    stubbedDone = sinon.stub();
    stubbedIt = sinon.stub().callsArgWith(1, stubbedDone);
    dummyServer = server.createServer(PORT);
    return dummyServer.listen(PORT, done);
  });

  after(() => dummyServer.close());

  it('should crawl the correct links', (done) => {
    crawler.startCrawl(config, stubbedIt);
    return setTimeout((() => {
      stubbedIt.callCount.should.eql(4);
      sinon.assert.calledWith(stubbedIt, `http://localhost:${PORT}/route1`);
      sinon.assert.calledWith(stubbedIt, `http://localhost:${PORT}/route2`);
      sinon.assert.calledWith(stubbedIt, `http://localhost:${PORT}/route4`);
      sinon.assert.calledWith(stubbedIt, `http://localhost:${PORT}/route3`);
      stubbedDone.callCount.should.eql(4);
      stubbedDone.alwaysCalledWith(null);
      return done();
    }), 1000);
  }); // wait for all the calls to finish. Might be a better way to do it

  it('should give an error when a crawled link gives an error status code', (done) => crawler.startCrawl(err_config, (url, cb) => cb((err) => {
    if (err) {
      return done();
    }
    return done('Bad status response while crawling should trigger a failed test');
  })));

  return describe('Additional validation', () => it('should call validate function', (done) => {
    const validate = sinon.stub().returns(true);
    const myconfig = _.extend(config, { validate });
    crawler.startCrawl(myconfig, stubbedIt);
    return setTimeout((() => {
      validate.callCount.should.eql(4);
      validate.args.should.containEql([`http://localhost:${PORT}/route1`, dummyServer.LINKS_AT_ROOT]);
      validate.args.should.containEql([`http://localhost:${PORT}/route2`, dummyServer.LINKS_IN_ARRAY]);
      validate.args.should.containEql([`http://localhost:${PORT}/route4`, dummyServer.LINKS_WITH_TEMPLATE]);
      validate.args.should.containEql([`http://localhost:${PORT}/route3`, dummyServer.LINKS_IN_OBJECT]);
      return done();
    }), 1000);
  }));
}); // wait for all the calls to finish. Might be a better way to do it

describe('Replacing getLinks', () => {
  let stubbedGetLinks = (function () {});

  beforeEach(() => {
    stubbedGetLinks = sinon.stub();
    sinon.spy(linkFinder, 'getLinks');
    return crawler.setConfig();
  });

  afterEach(() => {
    crawler.reset();
    return linkFinder.getLinks.restore();
  });

  it('should be able to replace getLinks function', () => {
    crawler.setConfig({ getLinks: stubbedGetLinks });
    crawler.getLinks(OK_RES);
    sinon.assert.notCalled(linkFinder.getLinks);
    sinon.assert.calledOnce(stubbedGetLinks);
    return assertCalledWith(stubbedGetLinks, 0, [OK_RES_BODY]);
  });

  return it('should call LinkFinder if no replacement passed in', () => {
    crawler.getLinks(OK_RES);
    return sinon.assert.calledOnce(linkFinder.getLinks);
  });
});

describe('Crawler', () => {
  beforeEach(() => {
    crawler.reset();
    return sinon.stub(linkFinder, 'getLinks');
  });

  afterEach(() => linkFinder.getLinks.restore());

  return describe('processResponse', () => {
    beforeEach(() => {
      sinon.stub(crawler, 'createItWithResult');
      return crawler.setConfig();
    });

    afterEach(() => crawler.createItWithResult.restore());

    it('should crawl links that have not previously been crawled', () => {
      linkFinder.getLinks.onCall(0).returns(['a', 'b', 'c', 'b']);
      linkFinder.getLinks.onCall(1).returns(['d', 'e', 'c', 'b']);

      crawler.processResponse('parent', OK_RES, null, () => {});
      crawler.processResponse('parent', OK_RES, null, () => {});

      crawler.createItWithResult.callCount.should.eql(5);
      sinon.assert.calledWith(crawler.createItWithResult, 'a');
      sinon.assert.calledWith(crawler.createItWithResult, 'b');
      sinon.assert.calledWith(crawler.createItWithResult, 'c');
      sinon.assert.calledWith(crawler.createItWithResult, 'd');
      return sinon.assert.calledWith(crawler.createItWithResult, 'e');
    });

    it('should crawl specified percentage of links', () => {
      crawler.setConfig({ samplePercentage: 75 });
      linkFinder.getLinks.onCall(0).returns(['a', 'b', 'c', 'd']);

      crawler.processResponse('parent', OK_RES, null, () => {});

      return crawler.createItWithResult.callCount.should.eql(3);
    });

    it('should crawl links with uri template', () => {
      linkFinder.getLinks.onCall(0).returns(['/{value1}?query={value2}{&value3}', 'b']);

      crawler.processResponse('parent', OK_RES, { value1: 'one', value2: 'two' }, () => {});

      crawler.createItWithResult.callCount.should.eql(2);
      sinon.assert.calledWith(crawler.createItWithResult, '/one?query=two');
      return sinon.assert.calledWith(crawler.createItWithResult, 'b');
    });

    it('by default should error from a bad response', (done) => crawler.processResponse('parent', BAD_RES, {}, (err) => {
      err.should.match(/status 503/);
      return done();
    }));

    it('can recover from a bad response', (done) => {
      crawler.setConfig({ recover() { return true; } });
      return crawler.processResponse('parent', BAD_RES, {}, (err) => {
        should.not.exist(err);
        return done();
      });
    });

    return it('does not run validators after recovering', (done) => {
      crawler.setConfig({
        recover() { return true; },
        validate() { throw new Error('should have a given value'); },
      });
      return crawler.processResponse('parent', BAD_RES, {}, (err) => {
        should.not.exist(err);
        return done();
      });
    });
  });
});
