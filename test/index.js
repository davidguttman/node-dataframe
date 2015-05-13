var tape = require('tape')
var _ = require('lodash')
var sprintf = require("sprintf-js").sprintf

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

tape('Filter', function(t) {
  var dimensions = [
    {value: 'firstName', title: 'First Name'},
    {value: 'lastName', title: 'Last Name'}
  ]

  var reduce = function(row, memo) {
    memo.count = (memo.count || 0) + 1
    return memo
  }

  var df = DataFrame({
    rows: data,
    dimensions: dimensions,
    reduce: reduce
  })

  var results = df.calculate({
    dimensions: ['Last Name', 'First Name'],
    filter: function(row) {
      return row['First Name'] === 'Maximilian'
    }
  })

  t.equal(results.length, 4, 'should have 3 result rows')

  results.forEach(function(result) {
    if (result._level !== 1) return
    t.equal(result['First Name'], 'Maximilian', 'should match name')
  })

  // var first = results[0]
  // t.equal(first._level, 0, 'should have level')
  // t.equal(first['Transaction Type'], 'invoice', 'should have transaction type')
  // t.equal(first.count, 3, 'should have count of 3')
  // t.notOk(first['First Name'], 'should not have First Name')

  // var second = results[1]
  // var third = results[2]

  // t.ok(second['First Name'], 'should have first name')
  // t.equal(third._level, 1, 'should have level')

  // t.equal(first.count, (second.count + third.count), 'counts should add up')
  // t.equal(first.amountTotal, (second.amountTotal + third.amountTotal), 'amountTotals should add up')

  t.end()
})


tape('Compact Usage', function(t) {
  var dimensions = [
    {value: 'firstName', title: 'First Name'},
    {value: 'lastName', title: 'Last Name'},
    {value: 'state', title: 'State'},
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
    dimensions: ['Transaction Type', 'First Name', 'Last Name', 'State'],
    sortBy: 'amountTotal',
    sortDir: 'desc',
    compact: true
  })

  var columns = [
    "Transaction Type",
    "First Name",
    "Last Name",
    "State",
    "count",
    "amountTotal"
  ];

  // uncomment below to get a nice table view of the results
  /*
  var format = "%20s %15s %15s %6s %5s %10s";
  console.log(sprintf.apply(this, [format].concat(columns)));
  results.map(function(row) {
    var values = [];
    columns.map(function(col, i) {
      if(i < row._level) {
        values.push("");
      } else {
        values.push(row[col] || "");
      }
    })
    console.log(sprintf.apply(this, [format].concat(values)));
  })
  */

  t.equal(results.length, 12, 'should have 12 result rows')

  var first = results[0]
  t.equal(first._level, 0, 'should have level')
  t.equal(first['Transaction Type'], 'invoice', 'should have transaction type')
  t.equal(first.count, 3, 'should have count of 3')
  t.notOk(first['First Name'], 'should not have First Name')

  var third = results[2]
  t.equal(third._level, 2, 'should have level')
  t.equal(third['Transaction Type'], 'invoice', 'should have transaction type')
  t.equal(third.count, 1, 'should have count of 1')
  t.equal(third['First Name'], 'Maximilian', 'should have First Name')

  var forth = results[3]
  t.equal(forth._level, 2, 'should have level')
  t.equal(forth.count, 1, 'should have count of 1')
  t.equal(forth['Last Name'], 'Batz', 'should have Last Name')
  t.equal(forth['amountTotal'], 844.95, 'should have amountTotal')

  t.end()
})

