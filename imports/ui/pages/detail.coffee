require '../components/timeline.coffee'

require '../lists/recentMentions.coffee'
require '../lists/frequentDescriptors.coffee'

require './detail.jade'


Template.detail.helpers
  agent: ->
    Router.current().getParams()._agentName
