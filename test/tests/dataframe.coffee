assert = require 'assert'

expectObj = (given, expected, message='') ->
  for k, v of expected
    expect given[k], v, "#{message}\n#{k}"

expect = (given, expected, message='') ->
  assert given is expected, "#{message}\ngiven: #{given}\nexpected: #{expected}"

DataFrame = require '../../src'

config = require '../fixtures/ua_config'

describe 'DataFrame', ->

  describe '#by()', ->
    df = null

    beforeEach ->
      df = new DataFrame

      df.set 'dimensions', config.dimensions
      df.set 'insert', config.insert
      df.by ['browser']

      for score in config.scores
        df.insert score

    it 'should add a dimension', ->
      list = df.list ['browser', 'os']
      expect list.length, 0, 'should be empty'
      
      df.by ['browser', 'os']
      list = df.list ['browser', 'os']

      expected =  [ 
        { browser: 'safari', os: 'osx', count: 2, score: 12 },
        { browser: 'chrome', os: 'osx', count: 1, score: 10 },
        { browser: 'ie', os: 'win', count: 1, score: 15 },
        { browser: 'chrome', os: 'win', count: 1, score: 20 } 
      ]

      expect list.length, expected.length, 'should match expected length'

      for item, i in expected
        expectObj list[i], expected[i], 'should match'
  
  describe '#set()', ->
    df = null
    
    beforeEach ->
      df = new DataFrame

    it 'should set dimensions', ->
      df.set 'dimensions', config.dimensions
      expect df.config.dimensions, config.dimensions
    
    it 'should set insert function', ->
      df.set 'insert', config.insert
      expect df.config.insert, config.insert

  describe '#list()', ->
    df = null

    beforeEach ->
      df = new DataFrame
      df.set 'dimensions', config.dimensions
      df.set 'insert', config.insert
      df.by ['browser', 'os']

      for score in config.scores
        df.insert score

    it 'should list by a single dimension', ->
      list = df.list 'browser'

      expected = [
        {"browser": "safari", "count": 2, "score": 12},
        {"browser": "chrome", "count": 2, "score": 30},
        {"browser": "ie", "count": 1, "score": 15}
      ]

      expect list.length, 3, 'should be 3 results'

      for item, i in expected
        expectObj list[i], expected[i], 'should match'

    it 'should list by two dimensions', ->
      list = df.list ['browser', 'os']

      expected =  [ 
        { browser: 'safari', os: 'osx', count: 2, score: 12 },
        { browser: 'chrome', os: 'osx', count: 1, score: 10 },
        { browser: 'ie', os: 'win', count: 1, score: 15 },
        { browser: 'chrome', os: 'win', count: 1, score: 20 } 
      ]

      expect list.length, expected.length, 'should match expected length'

      for item, i in expected
        expectObj list[i], expected[i], 'should match'