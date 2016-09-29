require './header.jade'
Feeds = require '../components/feeds.coffee'

Template.header.helpers
  feeds: ->
    Feeds.find()
  region: ->
    Feeds.findOne(Session.get('promedFeedId'))?.label or "All Feeds"

Template.header.events
  'click .region-selector li': (event, instance) ->
    Session.set('promedFeedId', @_id)
