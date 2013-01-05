module.exports = 
  dimensions:
    player:
      value: (doc) -> doc.player
    level:
      value: (doc) -> doc.level
    date:
      value: (doc) -> doc.date

  insert: (store, doc) ->
    store.count ?= 0
    store.count += 1

    store.score ?= 0
    store.score += doc.score

    store.shots ?= 0
    store.shots += doc.shots

    store.scorePerShot ?= 0
    store.scorePerShot += doc.score / doc.shots if doc.shots > 0

    return store
