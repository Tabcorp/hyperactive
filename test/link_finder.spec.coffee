should      = require 'should'
linkFinder  = require "#{SRC}/link_finder"

describe 'LinkFinder', ->
  it 'should return empty array when response does not contain any links', ->
    responseBody =
      a:1
      b:"hello world"
      c: [1,2,3]

    linkFinder.getLinks(responseBody).should.eql []

  it 'should return links that are in the root of the body', ->
    responseBody =
      a:1
      b:"hello world"
      c: [1,2,3]
      _links:
        linka: { href: "a" }
        linkb: { href: "b" }
        linkc: { href: "c" }

    linkFinder.getLinks(responseBody).should.eql ['a','b','c']


  it 'should return links that are in an array', ->
    responseBody =
      a:1
      b:"hello world"
      c: [
        { _links: { linka: { href: "a" }, linkb: { href: "b" }, linkc: { href: "c" }}}
        { _links: { linka: { href: "d" }, linkb: { href: "e" }, linkc: { href: "f" }}}
      ]

    linkFinder.getLinks(responseBody).should.eql ['a','b','c','d','e','f']

  it 'should return links recursively', ->
    responseBody =
      a:1
      b:"hello world"
      c: [
        { _links: { linka: { href: "a" }, linkb: { href: "b" }, linkc: { href: "c" }}}
        { _links: { linka: { href: "d" }, linkb: { href: "e" }, linkc: { href: "f" }}}
      ]
      d:
        e: { _links: { linka: { href: "g" }, linkb: { href: "h" }, linkc: { href: "i" }}}
        f: [
          { g: { h: { _links: { linka: { href: "j" }, linkb: { href: "k" }, linkc: { href: "l" }}}}}
        ]

    linkFinder.getLinks(responseBody).should.eql ['a','b','c','d','e','f','g','h','i','j','k','l']
