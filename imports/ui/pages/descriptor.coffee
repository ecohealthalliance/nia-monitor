require '../lists/recentDescriptorMentions.coffee'

require './descriptor.jade'

Template.descriptor.onCreated ->
  @ready = new ReactiveVar(false)

Template.descriptor.helpers
  descriptorName: ->
    Router.current().getParams()._descriptorName
  term: ->
    Router.current().getParams()._term
  ready: ->
    Template.instance().ready.get()
