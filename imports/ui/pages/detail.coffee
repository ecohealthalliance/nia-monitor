require '../components/timeline.coffee'
require '../components/detailLeft.coffee'
require '../components/detailRight.coffee'

require './detail.jade'


Template.detail.helpers
  agent: ->
    console.log Router.current().getParams()._agentName
    Router.current().getParams()._agentName
