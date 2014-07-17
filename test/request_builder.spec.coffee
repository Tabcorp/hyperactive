should  = require 'should'
build   = require "#{SRC}/request_builder"

describe 'RequestBuilder', ->

  URL = "http://abc.com"

  it 'should create a request if no config are provided', ->
    req = build.request URL
    req.should.have.property('options').have.properties
      url: URL
      method: "get"

  it 'should create a request with provided config', ->
    config =
      headers:
        Accept: 'application/json'
      auth:
        user: 'basicUser'
        pass: 'basicPassword'
      headers:
        Accept: 'application/json'
        'Content-type': 'application/json'
      strictSSL: true
      secureProtocol: 'mySecureProtocol'

    req = build.request URL, config
    req.should.have.property('options').have.properties
      url: URL
      method: "get"
      headers:
        Accept: 'application/json'
      auth:
        user: 'basicUser'
        pass: 'basicPassword'
      headers:
        Accept: 'application/json'
        'Content-type': 'application/json'
      strictSSL: true
      secureProtocol: 'mySecureProtocol'
