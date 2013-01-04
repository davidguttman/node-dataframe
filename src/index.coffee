reduce = require 'rolling-reduce'
events = require 'events'

class DataFrame extends events.EventEmitter
  constructor: (config) ->
    events.EventEmitter.call this

    @reducers = {}
    @dimensionSets = {}
    @docs = []
    @config = config or {}
    @config.selected ?= []

  getReducer: (key) ->
    unless @reducers[key.string]
      @reducers[key.string] = @createReducer key, @config

    @reducers[key.string]

  insert: (doc) ->
    @docs.push doc
    @reduce doc

  reduce: (doc, filters) ->
    reducerKeys = @getReducerKeys doc, @config
    for key in reducerKeys
      reducer = @getReducer key

      if filters
        reducer.insert doc if @multiFilterReducer reducer, filters
      else
        reducer.insert doc

      @emit 'result', reducer


  set: (key, value) ->
    @config[key] = value

  by: (dimensions) ->
    dimensions = [dimensions] if typeof dimensions is 'string'
    @config.selected = dimensions

    filters = []

    sets = @setsFromDimensions dimensions
    for set, filter of sets
      unless @dimensionSets[set]
        @dimensionSets[set] = filter
        filters.push @dimensionSets[set]

    for doc in @docs
      @reduce doc, filters


  setsFromDimensions: (dimensions) ->
    sets = {}
    for dimension, i in dimensions
      group = dimensions[0..i]
      sets[group.sort().join ','] = group

    return sets

  addDimension: (dimension) ->
    @config.selected.push dimension unless dimension in @config.selected

    for doc in @docs
      @reduce doc, [@config.selected]

  multiFilterReducer: (reducer, filters) ->
    isValid = false
    for filter in filters
      isValid = @filterReducer reducer, filter
      return true if isValid

    return isValid

  filterReducer: (reducer, filter) ->
    level = filter.length - 1

    if reducer.level is level
      valid = true
      for dimension in filter
        return valid = false unless reducer.criteria[dimension]?
      return valid
    else
      return false

  filterReducers: (filter) ->
    list = []
    for key, reducer of @reducers      
      list.push reducer if @filterReducer reducer, filter
    list

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

    reducers = @filterReducers dimensions
    results = reducers.map (reducer) -> reducer.result

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
