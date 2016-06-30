require './header.jade'
require './main.jade'

require '../lists/recentAgents.coffee'
require '../lists/frequentAgents.coffee'
require '../lists/trendingAgents.coffee'

Template.main.onRendered ->
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
