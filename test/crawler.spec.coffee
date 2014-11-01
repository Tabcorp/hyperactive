_           = require 'lodash'
should      = require 'should'
sinon       = require 'sinon'
crawler     = require "#{SRC}/crawler"
linkFinder  = require "#{SRC}/link_finder"
server      = require "./server"

assertCalledWithFirstArg = (stub, callIndex, expected) ->
  actual = stub.args[callIndex][0]
  actual.should.eql expected

assertCalledWith = (stub, callIndex, expected) ->
  actual = stub.args[callIndex]
  actual.should.eql expected

OK_RES_BODY = {totallyValid: 'res'}
OK_RES = {body: OK_RES_BODY, ok: true}
BAD_RES = { ok: false, status: 503, body: 'Server down' }

describe 'Crawler with server', ->
  stubbedIt = (->)
  stubbedDone = (->)
  dummyServer = null

  PORT = 6000
  config =
    url: "http://localhost:#{PORT}/{routeOne}"
    options:
      headers:
        Accept: 'application/json'
    templateValues:
      routeOne: 'route1'
      routeFour: 'route4'

  err_config =
    url: "http://localhost:#{PORT}/{routeOne}"
    options:
      headers:
        Accept: 'application/json'
    templateValues:
      routeOne: 'error'

  before (done) ->
    stubbedDone = sinon.stub()
    stubbedIt = sinon.stub().callsArgWith 1, stubbedDone
    dummyServer = server.createServer PORT
    dummyServer.listen PORT, done

  after ->
    dummyServer.close()

  it 'should crawl the correct links', (done) ->
    crawler.startCrawl config, stubbedIt
    setTimeout (->
      stubbedIt.callCount.should.eql 4
      sinon.assert.calledWith stubbedIt, "http://localhost:#{PORT}/route1"
      sinon.assert.calledWith stubbedIt, "http://localhost:#{PORT}/route2"
      sinon.assert.calledWith stubbedIt, "http://localhost:#{PORT}/route4"
      sinon.assert.calledWith stubbedIt, "http://localhost:#{PORT}/route3"
      stubbedDone.callCount.should.eql 4
      stubbedDone.alwaysCalledWith null
      done()
    ), 1000 # wait for all the calls to finish. Might be a better way to do it

  it 'should give an error when a crawled link gives an error status code', (done) ->
    crawler.startCrawl err_config, (url, cb) ->
      cb (err) ->
        if err
          done()
        else
          done('Bad status response while crawling should trigger a failed test')

  describe "Additional validation", ->
    it 'should call validate function', (done) ->
      validate = sinon.stub().returns true
      myconfig = _.extend config, { validate: validate }
      crawler.startCrawl myconfig, stubbedIt
      setTimeout (->
        validate.callCount.should.eql 4
        assertCalledWith validate, 0, [ "http://localhost:#{PORT}/route1", dummyServer.LINKS_AT_ROOT   ]
        assertCalledWith validate, 1, [ "http://localhost:#{PORT}/route2", dummyServer.LINKS_IN_ARRAY  ]
        assertCalledWith validate, 2, [ "http://localhost:#{PORT}/route4", dummyServer.LINKS_WITH_TEMPLATE ]
        assertCalledWith validate, 3, [ "http://localhost:#{PORT}/route3", dummyServer.LINKS_IN_OBJECT ]
        done()
      ), 1000 # wait for all the calls to finish. Might be a better way to do it



describe "Replacing getLinks", ->

  stubbedGetLinks = (->)

  beforeEach ->
    stubbedGetLinks = sinon.stub()
    sinon.spy(linkFinder, 'getLinks')
    crawler.setConfig()

  afterEach ->
    crawler.reset()
    linkFinder.getLinks.restore()

  it 'should be able to replace getLinks function', ->
    crawler.setConfig { getLinks: stubbedGetLinks }
    crawler.getLinks OK_RES
    sinon.assert.notCalled linkFinder.getLinks
    sinon.assert.calledOnce stubbedGetLinks
    assertCalledWith stubbedGetLinks, 0, [OK_RES_BODY]

  it 'should call LinkFinder if no replacement passed in', ->
    crawler.getLinks OK_RES
    sinon.assert.calledOnce linkFinder.getLinks

describe 'Crawler', ->

  beforeEach ->
    crawler.reset()
    sinon.stub(linkFinder, 'getLinks')

  afterEach ->
    linkFinder.getLinks.restore()

  describe 'processResponse', ->

    beforeEach ->
      sinon.stub(crawler, 'createItWithResult')
      crawler.setConfig()

    afterEach ->
      crawler.createItWithResult.restore()

    it 'should crawl links that have not previously been crawled', ->
      linkFinder.getLinks.onCall(0).returns ['a', 'b', 'c', 'b']
      linkFinder.getLinks.onCall(1).returns ['d', 'e', 'c', 'b']

      crawler.processResponse 'parent', OK_RES, null, ->
      crawler.processResponse 'parent', OK_RES, null, ->

      crawler.createItWithResult.callCount.should.eql 5
      sinon.assert.calledWith crawler.createItWithResult, 'a'
      sinon.assert.calledWith crawler.createItWithResult, 'b'
      sinon.assert.calledWith crawler.createItWithResult, 'c'
      sinon.assert.calledWith crawler.createItWithResult, 'd'
      sinon.assert.calledWith crawler.createItWithResult, 'e'

    it 'should crawl specified percentage of links', ->
      crawler.setConfig {samplePercentage: 75}
      linkFinder.getLinks.onCall(0).returns ['a', 'b', 'c', 'd']

      crawler.processResponse 'parent', OK_RES, null, ->

      crawler.createItWithResult.callCount.should.eql 3

    it 'should crawl links with uri template', ->
      linkFinder.getLinks.onCall(0).returns ['/{value1}?query={value2}{&value3}', 'b']

      crawler.processResponse 'parent', OK_RES, {value1: 'one', value2: 'two'}, ->

      crawler.createItWithResult.callCount.should.eql 2
      sinon.assert.calledWith crawler.createItWithResult, '/one?query=two'
      sinon.assert.calledWith crawler.createItWithResult,  'b'

    it 'by default should error from a bad response', (done) ->
      crawler.processResponse 'parent', BAD_RES, {}, (err) ->
        err.should.match /status 503/
        done()

    it 'can recover from a bad response', (done) ->
      crawler.setConfig {recover: -> true}
      crawler.processResponse 'parent', BAD_RES, {}, (err) ->
        should.not.exist err
        done()

    it 'does not run validators after recovering', (done) ->
      crawler.setConfig {
        recover: -> true
        validate: -> throw new Error('should have a given value')
      }
      crawler.processResponse 'parent', BAD_RES, {}, (err) ->
        should.not.exist err
        done()
