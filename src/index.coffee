reduce = require 'rolling-reduce'
events = require 'events'

class DataFrame extends events.EventEmitter
  constructor: (config) ->
    events.EventEmitter.call this

    @reducers = {}
    @config = config or {}

  getReducer: (key) ->
    unless @reducers[key.string]
      @reducers[key.string] = @createReducer key, @config

    @reducers[key.string]

  insert: (doc) ->
    reducerKeys = @getReducerKeys doc, @config
    for key in reducerKeys
      reducer = @getReducer key
      reducer.insert doc

      @emit 'result', reducer

  set: (key, value) ->
    @config[key] = value

  by: (dimensions) ->
    dimensions = [dimensions] if typeof dimensions is 'string'
    @config.selected = dimensions

  createReducer: (key, config) ->
    reducer = reduce extend {}, key.object
    reducer.criteria = key.object
    reducer.level = key.level
    reducer.on 'insert', config.insert

  getReducerKeys: (doc, config) ->
    reducerKeyObjs = []

    for selected in config.selected
      lastKey = reducerKeyObjs.slice(-1)[0]
      key = extend {}, lastKey
      key[selected] = config.dimensions[selected].value doc
      reducerKeyObjs.push key

    reducerKeys = reducerKeyObjs.map (obj) ->
      level = (getKeys obj).length - 1
      {object: obj, string: (toKeyString obj), level: level}
    
    return reducerKeys

  list: (dimensions) ->
    dimensions = [dimensions] if typeof dimensions is 'string'

    list = []

    for dimension, level in dimensions

      for key, reducer of @reducers
        if (reducer.level is level) and reducer.criteria[dimension]?
          list.push reducer.result

    list

module.exports = DataFrame

getKeys = (obj) ->
  keys = []
  for k, v of obj
    keys.push k
  return keys

getSortedKeys = (obj) ->
  return getKeys(obj).sort()

extend = (target, source) ->
  source = source or {}
  for k, v of source
    target[k] = v
  return target

toKeyString = (obj) ->
  valuePairs = getSortedKeys(obj).map (dKey) ->
    "#{dKey}:#{obj[dKey]}"
  keyString = valuePairs.join '|'
