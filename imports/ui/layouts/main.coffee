require './header.coffee'
require './main.jade'

require '../components/datacheck.coffee'
require '../lists/recentAgents.coffee'
require '../lists/frequentAgents.coffee'
require '../lists/trendingAgents.coffee'

Template.main.onRendered ->
  if localStorage.getItem('showAppDesc') != "false"
    $(".appDescriptionContainer").show()

Template.main.helpers
  view: ->
    switch Router.current().getParams()._view
      when "trending" then "trendingAgents"
      when "frequent" then "frequentAgents"
      else "recentAgents"

Template.main.events
  'click #hideAppDesc': (event, instance) ->
    $(".appDescriptionContainer").hide()
    localStorage.setItem('showAppDesc', false)
  'click #showAppDesc': (event, instance) ->
    $(".appDescriptionContainer").show()
    localStorage.setItem('showAppDesc', true)
