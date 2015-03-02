var tape = require('tape')

var DataFrame = require('..')

var data = require('./data.json')

tape('Basic Usage', function(t) {
  var dimensions = [
    {value: 'firstName', title: 'First Name'},
    {value: function(row) {
      return row.transaction.type
    }, title: 'Transaction Type'}
  ]

  var reduce = function(row, memo) {
    memo.count = (memo.count || 0) + 1
    memo.amountTotal = (memo.amountTotal || 0) + parseFloat(row.transaction.amount)
    return memo
  }

  var df = DataFrame({
    rows: data,
    dimensions: dimensions,
    reduce: reduce
  })

  var results = df.calculate({
    dimensions: ['Transaction Type', 'First Name'],
    sortBy: 'amountTotal',
    sortDir: 'desc'
  })

  t.equal(results.length, 10, 'should have 10 result rows')

  var first = results[0]
  t.equal(first._level, 0, 'should have level')
  t.equal(first['Transaction Type'], 'invoice', 'should have transaction type')
  t.equal(first.count, 3, 'should have count of 3')
  t.notOk(first['First Name'], 'should not have First Name')

  var second = results[1]
  var third = results[2]

  t.ok(second['First Name'], 'should have first name')
  t.equal(third._level, 1, 'should have level')

  t.equal(first.count, (second.count + third.count), 'counts should add up')
  t.equal(first.amountTotal, (second.amountTotal + third.amountTotal), 'amountTotals should add up')


  t.end()
})
