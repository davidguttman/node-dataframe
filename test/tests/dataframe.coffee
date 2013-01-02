require 'should'

DataFrame = require '../../src'

describe 'DataFrame', ->
  it 'constructor should be a function', ->
    
    DataFrame.should.be.a 'function'