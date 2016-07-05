Session.setDefault('now', +new Date)

tickInterval = 1000

tick = ->
  Session.set('now', Session.get('now') + tickInterval)

setInterval tick, tickInterval

Template.registerHelper 'age', (date) ->
  Session.get('now') # triggers the reactivity every second
  moment(date).fromNow()

Template.registerHelper 'since', (date, priorDate) ->
  moment(priorDate).from(date).replace('ago', '')
