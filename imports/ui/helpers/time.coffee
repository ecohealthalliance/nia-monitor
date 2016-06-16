Session.setDefault('now', +new Date)

tickInterval = 1000

tick = ->
  Session.set('now', Session.get('now') + tickInterval)
setInterval tick, tickInterval

# This IIFE wrapper gets compiled only once
talkTime = do ->
  # Cache strings to be used as pointers instead
  #          of being re-defined upon every call
  second = 'second'
  minute = 'minute'
  hour   = 'hour'
  day    = 'day'
  week   = 'week'
  month  = 'month'
  year   = 'year'

  # Define the inner function to be returned to this IIFE
  timer = (time) ->
    count = 0
    unit = second
    time = Math.floor(time)
    if time < 60
      count = if time < 1 then 1 else time
    else if count = Math.floor(time / (60 * 60 * 24 * 365))
      unit = year
    else if count = Math.floor(time / (60 * 60 * 24 * 30))
      unit = month
    else if count = Math.floor(time / (60 * 60 * 24 * 7))
      unit = week
    else if count = Math.floor(time / (60 * 60 * 24))
      unit = day
    else if count = Math.floor(time / (60 * 60))
      unit = hour
    else
      count = Math.floor(time % 60 * 60 / 60)
      unit = minute
    "#{count} #{unit}#{(if count isnt 1 then 's')}"

  # Wrap the inner function to be returned
  (second) ->
    timer second


Template.registerHelper 'age', (date) ->
  talkTime( (Session.get('now') - new Date(date)) / 1000 ) + ' ago'
