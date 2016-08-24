require './header.jade'

Template.header.onCreated ->
  @Feeds = require '../components/feeds.coffee'

Template.header.helpers
  feed: ->
    Template.instance().Feeds.find()
  region: ->
    Session.get('region')

Template.header.events
  'click .regionSelector': (event, instance) ->
    Session.set('region', event.toElement.attributes.region.value)
    $(Session.get("currentTab")).empty()
    Blaze.renderWithData(Template[Session.get("currentTemplate")], {regionFeed: Session.get('region')}, $(Session.get("currentTab"))[0])
