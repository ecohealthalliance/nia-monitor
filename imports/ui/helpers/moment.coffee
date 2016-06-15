Template.registerHelper 'moment', (date, format) ->
  moment(date).format('MM/DD/YYYY \\at HH:MMa')
