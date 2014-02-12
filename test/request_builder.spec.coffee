should  = require 'should'
build   = require "#{SRC}/request_builder"

describe 'RequestBuilder', ->

  URL = "http://abc.com"

  it 'should create a request if no config are provided', ->
    req = build.request URL
    req.options.url.should.eql URL
    req.options.method.should.eql "get"

  it 'should create a request with accept header', ->
    config =
      headers:
        Accept: 'application/json'

    req = build.request URL, config
    req.options.url.should.eql URL
    req.options.method.should.eql "get"
    req.options.headers.Accept.should.eql 'application/json'

  it 'should create a request with basic auth', ->
    config =
      basicAuth:
        user: 'basicUser'
        pass: 'basicPassword'

    req = build.request URL, config
    req.options.url.should.eql URL
    req.options.method.should.eql "get"

    req.options.auth.user.should.eql 'basicUser'
    req.options.auth.password.should.eql 'basicPassword'

  it 'should create a request with accept header and basic auth', ->
    config =
      headers:
        Accept: 'application/json'
      basicAuth:
        user: 'basicUser'
        pass: 'basicPassword'

    req = build.request URL, config
    req.options.url.should.eql URL
    req.options.method.should.eql "get"
    req.options.headers.Accept.should.eql 'application/json'
    req.options.auth.user.should.eql 'basicUser'
    req.options.auth.password.should.eql 'basicPassword'

  it 'should create a request with multiple headers', ->
    config =
      headers:
        Accept: 'application/json'
        'Content-type': 'application/json'

    req = build.request URL, config
    req.options.url.should.eql URL
    req.options.method.should.eql "get"
    req.options.headers.Accept.should.eql 'application/json'
    req.options.headers['Content-type'].should.eql 'application/json'

  it 'should create a request with strictSSL set to false', ->
    config =
      strictSSL: false

    req = build.request URL, config
    req.options.url.should.eql URL
    req.options.method.should.eql "get"
    req.options.strictSSL.should.eql false

  it 'should create a request with strictSSL set to true', ->
    config =
      strictSSL: true

    req = build.request URL, config
    req.options.url.should.eql URL
    req.options.method.should.eql "get"
    req.options.strictSSL.should.eql true

  it 'should create a request with specified secureProtocol', ->
    config =
      secureProtocol: 'mySecureProtocol'

    req = build.request URL, config
    req.options.url.should.eql URL
    req.options.method.should.eql "get"
    req.options.secureProtocol.should.eql 'mySecureProtocol'
