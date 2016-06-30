require '../lists/recentDescriptorMentions.coffee'

require './descriptor.jade'


Template.descriptor.helpers
  agent: ->
    Router.current().getParams()._agentName
