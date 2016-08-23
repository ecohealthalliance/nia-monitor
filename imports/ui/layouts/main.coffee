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

  Blaze.renderWithData(Template.recentAgents, {regionFeed: @regionFeed}, $("#recentlyMentionedInfectiousAgents")[0])
  @currentTab.set("#recentlyMentionedInfectiousAgents")
  @currentTemplate.set(Template.recentAgents)
Template.main.events
  'click #recentPanelTab': (event, instance) ->
    $("#recentlyMentionedInfectiousAgents").empty()
    instance.currentTab.set("#recentlyMentionedInfectiousAgents")
    instance.currentTemplate.set(Template.recentAgents)
    Blaze.renderWithData(Template.recentAgents, {regionFeed: instance.regionFeed}, $("#recentlyMentionedInfectiousAgents")[0])
  'click #frequentPanelTab': (event, instance) ->
    $("#frequentlyMentionedInfectiousAgents").empty()
    instance.currentTab.set("#frequentlyMentionedInfectiousAgents")
    instance.currentTemplate.set(Template.frequentAgents)
    Blaze.renderWithData(Template.frequentAgents, {regionFeed: instance.regionFeed}, $("#frequentlyMentionedInfectiousAgents")[0])
  'click #trendingPanelTab': (event, instance) ->
    $("#trendingInfectiousAgents").empty()
    instance.currentTab.set("#trendingInfectiousAgents")
    instance.currentTemplate.set(Template.trendingAgents)
    Blaze.renderWithData(Template.trendingAgents, {regionFeed: instance.regionFeed}, $("#trendingInfectiousAgents")[0])
  'click #hideAppDesc': (event, instance) ->
    $(".appDescriptionContainer").hide()
    localStorage.setItem('showAppDesc', false)
  'click #showAppDesc': (event, instance) ->
    $(".appDescriptionContainer").show()
    localStorage.setItem('showAppDesc', true)
  'change #regionSelector': (event, instance) ->
    Template.instance().regionFeed.set($("#regionSelector").val())
    $(instance.currentTab.get()).empty()
    Blaze.renderWithData(instance.currentTemplate.get(), {regionFeed: Template.instance().regionFeed.get()}, $(instance.currentTab.get())[0])

Template.main.helpers
  feed: ->
    Template.instance().Feeds.find()

Template.main.onCreated ->
  @regionFeed = new ReactiveVar("All")
  @currentTab = new ReactiveVar("null")
  @currentTemplate = new ReactiveVar("null")
  @Feeds = require '../components/feeds.coffee'
