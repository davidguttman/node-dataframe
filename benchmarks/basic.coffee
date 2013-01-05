DataFrame = require '../src'

players = require './players.json'
config = require './basic_config'

df = new DataFrame
df.set 'dimensions', config.dimensions
df.set 'insert', config.insert

nPlayers = players.length
console.log 'n:', nPlayers

for player in players
  df.insert player

t0 = Date.now()
df.by ['player']
t1 = Date.now()

e1 = t1-t0
console.log 'elapsed:', e1
console.log 'n/ms:', nPlayers/(e1)
console.log '-------'

t2 = Date.now()
df.by ['player', 'level']
t3 = Date.now()

e2 = t3-t2
console.log 'elapsed:', e2
console.log 'n/ms:', nPlayers/(e2)
console.log '-------'

t4 = Date.now()
df.by ['player', 'level', 'date']
t5 = Date.now()

e3 = t5-t4
console.log 'elapsed:', e3
console.log 'n/ms:', nPlayers/(e3)
console.log '-------'