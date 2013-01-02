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

  describe '#by()', ->
    it 'should set group by'
    # df.by ['browser', 'os']