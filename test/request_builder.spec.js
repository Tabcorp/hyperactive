/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const should  = require('should');
const build   = require(`${SRC}/request_builder`);

describe('RequestBuilder', function() {

  const URL = "http://abc.com";

  it('should create a request if no config are provided', function() {
    const req = build.request(URL);
    return req.should.have.property('options').have.properties({
      url: URL,
      method: "get"
    });
  });

  return it('should create a request with provided config', function() {
    const config = {
      headers: {
        Accept: 'application/json'
      },
      auth: {
        user: 'basicUser',
        pass: 'basicPassword'
      },
      headers: {
        Accept: 'application/json',
        'Content-type': 'application/json'
      },
      strictSSL: true,
      secureProtocol: 'mySecureProtocol'
    };

    const req = build.request(URL, config);
    return req.should.have.property('options').have.properties({
      url: URL,
      method: "get",
      headers: {
        Accept: 'application/json'
      },
      auth: {
        user: 'basicUser',
        pass: 'basicPassword'
      },
      headers: {
        Accept: 'application/json',
        'Content-type': 'application/json'
      },
      strictSSL: true,
      secureProtocol: 'mySecureProtocol'
    });
  });
});
