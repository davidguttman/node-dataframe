module.exports = 
  dimensions:
    os:
      title: "Operating System"
      value: (doc) -> doc.os
    browser:
      title: "Browser"
      value: (doc) -> doc.browser

  insert: (store, doc) ->
    store.count ?= 0
    store.count += 1

    store.score ?= 0
    store.score += doc.score

    return store