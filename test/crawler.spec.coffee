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
      assertCalledWithFirstArg stubbedIt, 0, "http://localhost:#{PORT}/route1"
      assertCalledWithFirstArg stubbedIt, 1, "http://localhost:#{PORT}/route2"
      assertCalledWithFirstArg stubbedIt, 2, "http://localhost:#{PORT}/route4"
      assertCalledWithFirstArg stubbedIt, 3, "http://localhost:#{PORT}/route3"
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

  afterEach ->
    crawler.reset()
    linkFinder.getLinks.restore()

  it 'should be able to replace getLinks function', ->
    crawler.setConfig { getLinks: stubbedGetLinks }
    crawler.getLinks OK_RES
    linkFinder.getLinks.callCount.should.eql 0
    stubbedGetLinks.callCount.should.eql 1
    assertCalledWith stubbedGetLinks, 0, [OK_RES_BODY]

  it 'should call LinkFinder if no replacement passed in', ->
    crawler.getLinks OK_RES
    linkFinder.getLinks.callCount.should.eql 1

describe 'Crawler', ->

  beforeEach ->
    crawler.reset()
    sinon.stub(linkFinder, 'getLinks')

  afterEach ->
    linkFinder.getLinks.restore()

  describe 'processResponse', ->

    beforeEach ->
      sinon.stub(crawler, 'crawl')

    afterEach ->
      crawler.crawl.restore()

    it 'should crawl links that have not previously been crawled', ->
      linkFinder.getLinks.onCall(0).returns ['a', 'b', 'c', 'b']
      linkFinder.getLinks.onCall(1).returns ['d', 'e', 'c', 'b']

      crawler.processResponse 'parent', OK_RES, null, ->
      crawler.processResponse 'parent', OK_RES, null, ->

      crawler.crawl.callCount.should.eql 5
      assertCalledWith crawler.crawl, 0, ['a']
      assertCalledWith crawler.crawl, 1, ['b']
      assertCalledWith crawler.crawl, 2, ['c']
      assertCalledWith crawler.crawl, 3, ['d']
      assertCalledWith crawler.crawl, 4, ['e']

    it 'should crawl specified percentage of links', ->
      crawler.setConfig {samplePercentage: 75}
      linkFinder.getLinks.onCall(0).returns ['a', 'b', 'c', 'd']

      crawler.processResponse 'parent', OK_RES, null, ->

      crawler.crawl.callCount.should.eql 3

    it 'should crawl links with uri template', ->
      linkFinder.getLinks.onCall(0).returns ['/{value1}?query={value2}{&value3}', 'b']

      crawler.processResponse 'parent', OK_RES, {value1: 'one', value2: 'two'}, ->

      crawler.crawl.callCount.should.eql 2
      assertCalledWith crawler.crawl, 0, ['/one?query=two']
      assertCalledWith crawler.crawl, 1, ['b']
