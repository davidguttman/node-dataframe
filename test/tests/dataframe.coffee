assert = require 'assert'
expect = (given, expected, message='') ->
  assert given is expected, "#{message}\ngiven: #{given}\nexpected: #{expected}"

DataFrame = require '../../src'

config = require '../fixtures/ua_config'

describe 'DataFrame', ->
  
  describe '#set()', ->
    df = null
    
    before ->
      df = new DataFrame

    it 'should set dimensions', ->
      df.set 'dimensions', config.dimensions
      expect df.config.dimensions, config.dimensions
    
    it 'should set insert function', ->
      df.set 'insert', config.insert
      expect df.config.insert, config.insert

  describe '#list()', ->
    df = null

    before ->
      df = new DataFrame
      df.set 'dimensions', config.dimensions
      df.set 'insert', config.insert

    it 'should list by a single dimension', ->
      df.by ['browser', 'os']

      for score in config.scores
        df.insert score

      list = df.list 'browser'

      expected = [
        {"browser": "safari", "count": 2, "score": 12},
        {"browser": "chrome", "count": 2, "score": 30},
        {"browser": "ie", "count": 1, "score": 15}
      ]

      expect list.length, 3, 'should be 3 results'

      for expectation, i in expected
        expect list[i].browser, expectation.browser, 'browser should match'
        expect list[i].score, expectation.score, 'score should match'