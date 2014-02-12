_           = require 'lodash'
should      = require 'should'
linkFilter  = require "#{SRC}/link_filter"

describe 'LinkFilter', ->

  beforeEach ->
    linkFilter.reset()

  describe 'unprocessedLinks', ->

    it 'should get unique links', ->
      linkFilter.unprocessedLinks(['a', 'b', 'c', 'b']).should.eql ['a', 'b', 'c']

    it 'should only get links that are unprocessed', ->
      linkFilter.processLink 'a'
      linkFilter.unprocessedLinks(['a', 'b', 'c']).should.eql ['b', 'c']

  describe 'linksToSample', ->

    it 'should return correct percentage', ->
      linkFilter.linksToSample(4, 75).should.eql 3

    it 'should always return an int', ->
      linkFilter.linksToSample(4, 65).should.eql 3

    it 'should return 1', ->
      linkFilter.linksToSample(9, 10).should.eql 1

  describe 'filter', ->

    it 'should return all links if percentage not defined', ->
      linkFilter.filter(['a', 'b', 'c', 'd']).should.eql ['a', 'b', 'c', 'd']

    it 'should return a percentage of links', ->
      linkFilter.filter(['a', 'b', 'c', 'd'], 75).length.should.eql 3