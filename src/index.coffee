reduce = require 'rolling-reduce'
util = require 'util'
events = require 'events'

getSortedKeys = (obj) ->
  keys = []
  for k, v of obj
    keys.push k
  return keys.sort()


extend = (target, source) ->
  source = source or {}
  for k, v of source
    target[k] = v
  return target

createReducer = (key, config) ->
  reducer = reduce extend {}, key.object
  reducer.on 'insert', config.insert

toKeyString = (obj) ->
  valuePairs = getSortedKeys(obj).map (dKey) ->
    "#{dKey}:#{obj[dKey]}"
  keyString = valuePairs.join '|'


getReducerKeys = (doc, config) ->
  reducerKeyObjs = []

  for selected in config.selected
    lastKey = reducerKeyObjs.slice(-1)[0]
    key = extend {}, lastKey
    key[selected] = config.dimensions[selected].value doc  
    reducerKeyObjs.push key

  reducerKeys = reducerKeyObjs.map (obj) ->
    {object: obj, string: toKeyString obj}
  
  return reducerKeys

DataFrame = (config) ->
  self = this

  events.EventEmitter.call this

  self.reducers = {}
  self.config = config or {}

  getReducer = (key) ->
    unless self.reducers[key.string]
      self.reducers[key.string] = createReducer key, self.config

    self.reducers[key.string]

  self.insert = (doc) ->
    reducerKeys = getReducerKeys doc, self.config
    for key in reducerKeys
      reducer = getReducer key
      reducer.insert doc

      self.emit 'result', reducer

  self.set = (key, value) ->
    self.config[key] = value

  self.by = (dimensions) ->
    dimensions = [dimensions] if typeof dimensions is 'string'
    self.config.selected = dimensions

  return this

util.inherits DataFrame, events.EventEmitter

module.exports = DataFrame