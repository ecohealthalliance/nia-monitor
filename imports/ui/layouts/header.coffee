require './header.jade'
Feeds = require '../components/feeds.coffee'

Template.header.helpers
  feeds: ->
    Feeds.find()
  region: ->
    Feeds.findOne(Session.get('promedFeedId'))?.label or "All Feeds"

Template.header.events
  'click .dropdown, mouseover .dropdown': (event, instance) ->
    instance.$(event.currentTarget).addClass('open')

  'mouseout .dropdown': (event, instance) ->
    instance.$(event.currentTarget).removeClass('open').blur()

  'click .region-selector li, touchend .region-selector li': (event, instance) ->
    instance.$('.dropdown').removeClass('open').blur()
    Session.set('promedFeedId', @_id)
