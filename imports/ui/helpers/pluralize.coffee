pluralize = (what, count) ->
  s = if count isnt 1 then 's' else ''
  count + ' ' + what + s

Template.registerHelper 'pluralize', pluralize
