require '../components/timeline.coffee'

require '../lists/recentMentions.coffee'
require '../lists/frequentDescriptors.coffee'

require './detail.jade'

Template.detail.onCreated ->
  @selectedRangeRV = new ReactiveVar()

Template.detail.helpers
  agent: ->
    Router.current().getParams()._agentName
  selectedRangeRV: ->
    Template.instance().selectedRangeRV
  recentMentionsView: ->
    view = Router.current().getParams()._view
    if view
      view == "recentMentions"
    else
      true
  frequentDescriptorsView: ->
    Router.current().getParams()._view == "frequentDescriptors"
