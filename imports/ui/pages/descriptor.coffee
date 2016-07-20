require '../lists/recentDescriptorMentions.coffee'

require './descriptor.jade'

Template.descriptor.onCreated ->
  @ready = new ReactiveVar(false)
  @descriptor = Router.current().getParams()._descriptorName

Template.descriptor.helpers
  descriptorName: ->
    Router.current().getParams()._descriptorName
  ready: ->
    Template.instance().ready.get()
