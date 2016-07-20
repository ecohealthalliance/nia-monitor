require './header.jade'
require './main.jade'

require '../components/datacheck.coffee'
require '../lists/recentAgents.coffee'
require '../lists/frequentAgents.coffee'
require '../lists/trendingAgents.coffee'

Template.main.onRendered ->
  if localStorage.getItem('showAppDesc') != "false"
    $(".appDescriptionContainer").show()

  Blaze.render(Template.recentAgents, $("#recentlyMentionedInfectiousAgents")[0])

Template.main.events
  'click #recentPanelTab': (event, instance) ->
    $("#recentlyMentionedInfectiousAgents").empty()
    Blaze.render(Template.recentAgents, $("#recentlyMentionedInfectiousAgents")[0])
  'click #frequentPanelTab': (event, instance) ->
    $("#frequentlyMentionedInfectiousAgents").empty()
    Blaze.render(Template.frequentAgents, $("#frequentlyMentionedInfectiousAgents")[0])
  'click #trendingPanelTab': (event, instance) ->
    $("#trendingInfectiousAgents").empty()
    Blaze.render(Template.trendingAgents, $("#trendingInfectiousAgents")[0])
  'click #hideAppDesc': (event, instance) ->
    $(".appDescriptionContainer").hide()
    localStorage.setItem('showAppDesc', false)
  'click #showAppDesc': (event, instance) ->
    $(".appDescriptionContainer").show()
    localStorage.setItem('showAppDesc', true)
