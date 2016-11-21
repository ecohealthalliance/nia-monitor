Session.setDefault('now', +new Date)

tickInterval = 1000

tick = ->
  Session.set('now', Session.get('now') + tickInterval)

setInterval tick, tickInterval

Template.registerHelper 'format', (date, formatString) ->
  moment(date).format(formatString)

Template.registerHelper 'age', (date) ->
  Session.get('now') # triggers the reactivity every second
  moment(date).local().fromNow()

Template.registerHelper 'since', (date, priorDate) ->
  moment(priorDate).from(date).replace('ago', '')

# Return a relative age for recent dates, or formatted date for old dates.
Template.registerHelper 'ageOrDate', (date) ->
  if moment.duration(moment().diff(date)) > moment.duration(.9, 'months')
    moment(date).local().format("MMM Do YYYY")
  else
    moment(date).local().fromNow()
