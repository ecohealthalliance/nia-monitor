require './header.jade'

if Session.get('region') == undefined
  Session.set('region', "All Regions")

Template.header.onCreated ->
  @Feeds = require '../components/feeds.coffee'

Template.header.helpers
  feed: ->
    Template.instance().Feeds.find()
  region: ->
    Session.get('region')

Template.header.events
  'click .regionSelector': (event, instance) ->
    Session.set('region', event.target.text)
