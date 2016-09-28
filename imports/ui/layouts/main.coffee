require './header.coffee'
require './main.jade'

require '../components/datacheck.coffee'
require '../lists/recentAgents.coffee'
require '../lists/frequentAgents.coffee'
require '../lists/trendingAgents.coffee'

Template.main.onCreated ->
  state = if localStorage.getItem('showAppDesc') != 'false' then true
  @showDescription = new ReactiveVar state or false

Template.main.helpers
  view: ->
    switch Router.current().getParams()._view
      when "trending" then "trendingAgents"
      when "frequent" then "frequentAgents"
      else "recentAgents"

Template.main.helpers
  showDescription: ->
    Template.instance().showDescription.get()

Template.main.events
  'click .hide-app-desc': (event, instance) ->
    instance.showDescription.set false
    localStorage.setItem('showAppDesc', false)
  'click .show-app-desc': (event, instance) ->
    instance.showDescription.set true
    localStorage.setItem('showAppDesc', true)
