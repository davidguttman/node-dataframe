DataFrame = require '../src'

scores = [
  {"score": 5, "os": "osx", "browser": "safari", "version": "5"},
  {"score": 7, "os": "osx", "browser": "safari", "version": "5"},
  {"score": 10, "os": "osx", "browser": "chrome", "version": "22"},
  {"score": 15, "os": "win", "browser": "ie", "version": "8"},
  {"score": 20, "os": "win", "browser": "chrome", "version": "21"}
]

df = new DataFrame

df.set 'dimensions',   
  os:
    title: "Operating System"
    value: (doc) -> doc.os
  browser:
    title: "Browser"
    value: (doc) -> doc.browser
  version:
    title: "Version"
    value: (doc) -> doc.version

df.set 'insert', (store, doc) ->
  store.count ?= 0
  store.count += 1

  store.score ?= 0
  store.score += doc.score

  return store

df.by ['browser']

for score in scores
  df.insert score

df.addDimension 'os'

os = df.list ['browser', 'os']
console.log 'os', os