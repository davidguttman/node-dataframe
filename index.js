var DataFrame, createReducer, events, extend, getReducerKeys, getSortedKeys, reduce, toKeyString, util;

reduce = require('rolling-reduce');

util = require('util');

events = require('events');

getSortedKeys = function(obj) {
  var k, keys, v;
  keys = [];
  for (k in obj) {
    v = obj[k];
    keys.push(k);
  }
  return keys.sort();
};

extend = function(target, source) {
  var k, v;
  source = source || {};
  for (k in source) {
    v = source[k];
    target[k] = v;
  }
  return target;
};

createReducer = function(key, config) {
  var reducer;
  reducer = reduce(extend({}, key.object));
  return reducer.on('insert', config.insert);
};

toKeyString = function(obj) {
  var keyString, valuePairs;
  valuePairs = getSortedKeys(obj).map(function(dKey) {
    return "" + dKey + ":" + obj[dKey];
  });
  return keyString = valuePairs.join('|');
};

getReducerKeys = function(doc, config) {
  var key, lastKey, reducerKeyObjs, reducerKeys, selected, _i, _len, _ref;
  reducerKeyObjs = [];
  _ref = config.selected;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    selected = _ref[_i];
    lastKey = reducerKeyObjs.slice(-1)[0];
    key = extend({}, lastKey);
    key[selected] = config.dimensions[selected].value(doc);
    reducerKeyObjs.push(key);
  }
  reducerKeys = reducerKeyObjs.map(function(obj) {
    return {
      object: obj,
      string: toKeyString(obj)
    };
  });
  return reducerKeys;
};

DataFrame = function(config) {
  var getReducer, self;
  self = this;
  events.EventEmitter.call(this);
  self.reducers = {};
  self.config = config;
  getReducer = function(key) {
    if (!self.reducers[key.string]) {
      self.reducers[key.string] = createReducer(key, self.config);
    }
    return self.reducers[key.string];
  };
  self.insert = function(doc) {
    var key, reducer, reducerKeys, _i, _len, _results;
    reducerKeys = getReducerKeys(doc, config);
    _results = [];
    for (_i = 0, _len = reducerKeys.length; _i < _len; _i++) {
      key = reducerKeys[_i];
      reducer = getReducer(key);
      reducer.insert(doc);
      _results.push(self.emit('result', reducer));
    }
    return _results;
  };
  return this;
};

util.inherits(DataFrame, events.EventEmitter);

module.exports = DataFrame;