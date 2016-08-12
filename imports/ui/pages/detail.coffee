require '../components/timeline.coffee'

require '../lists/recentMentions.coffee'
require '../lists/frequentDescriptors.coffee'

require './detail.jade'

Template.detail.onRendered ->
  @tlf = new ReactiveVar(null) #timeline filter
  Blaze.render(Template.recentMentions, $("#recentMentions")[0])

Template.detail.events
  'click #timelinePanelTab': (event, instance) ->
    $("#timeline").empty()
    Blaze.render(Template.timeline, $("#timeline")[0])
  'click #frequentDescriptorsPanelTab': (event, instance) ->
    $("#frequentDescriptors").empty()
    Blaze.renderWithData(Template.frequentDescriptors, this, $("#frequentDescriptors")[0])
  'click #recentMentionsPanelTab': (event, instance) ->
    $("#recentMentions").empty()
    Blaze.render(Template.recentMentions, $("#recentMentions")[0])

Template.detail.helpers
  agent: ->
    Router.current().getParams()._agentName
