require './header.jade'
require './main.jade'

require '../components/datacheck.coffee'
require '../lists/recentAgents.coffee'
require '../lists/frequentAgents.coffee'
require '../lists/trendingAgents.coffee'


Template.main.onRendered ->
  Blaze.render(Template.recentAgents, @find("#recentlyMentionedInfectiousAgents"))

Template.main.events
  'click #recentPanelTab': (event, instance) ->
    targetNode = instance.find("#recentlyMentionedInfectiousAgents")
    instance.$(targetNode).empty()
    Blaze.render(Template.recentAgents, targetNode)
  'click #frequentPanelTab': (event, instance) ->
    targetNode = instance.find("#frequentlyMentionedInfectiousAgents")
    instance.$(targetNode).empty()
    Blaze.render(Template.frequentAgents, targetNode)
  'click #trendingPanelTab': (event, instance) ->
    targetNode = instance.find("#trendingInfectiousAgents")
    instance.$(targetNode).empty()
    Blaze.render(Template.trendingAgents, targetNode)
