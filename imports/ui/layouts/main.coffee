require './header.jade'
require './main.jade'

require '../components/datacheck.coffee'
require '../lists/recentAgents.coffee'
require '../lists/frequentAgents.coffee'
require '../lists/trendingAgents.coffee'

Template.main.onRendered ->
  $(document).ready(() ->
    $("#regionSelector").select2({
      placeholder: "Select a Feed..."
    })
  )
  if localStorage.getItem('showAppDesc') != "false"
    $(".appDescriptionContainer").show()

  Blaze.render(Template.recentAgents, $("#recentlyMentionedInfectiousAgents")[0])

Template.main.events
  'click #recentPanelTab': (event, instance) ->
    $("#recentlyMentionedInfectiousAgents").empty()
    Blaze.render(Template.recentAgents, $("#recentlyMentionedInfectiousAgents")[0])
  'click #frequentPanelTab': (event, instance) ->
    $("#frequentlyMentionedInfectiousAgents").empty()
    Blaze.render(Template.frequentAgents, $("#frequentlyMentionedInfectiousAgents")[0])
    #TODO change to render with data
  'click #trendingPanelTab': (event, instance) ->
    $("#trendingInfectiousAgents").empty()
    Blaze.render(Template.trendingAgents, $("#trendingInfectiousAgents")[0])
  'click #hideAppDesc': (event, instance) ->
    $(".appDescriptionContainer").hide()
    localStorage.setItem('showAppDesc', false)
  'click #showAppDesc': (event, instance) ->
    $(".appDescriptionContainer").show()
    localStorage.setItem('showAppDesc', true)
  'change #regionSelector': (event, instance) ->
    Template.instance().regionFeed.set($("#regionSelector").val())

Template.main.helpers
  feed: ->
    Template.instance().Feeds.find()

Template.main.onCreated ->
  @regionFeed = new ReactiveVar("All")
  @Feeds = require '../components/feeds.coffee'
