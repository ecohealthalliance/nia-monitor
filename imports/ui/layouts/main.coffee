require './header.coffee'
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
  if Session.get('region') == undefined
    Session.set('region', "All Regions")
  Blaze.renderWithData(Template.recentAgents, {regionFeed: Session.get('region')}, $("#recentlyMentionedInfectiousAgents")[0])
  Session.set("currentTab", "#recentlyMentionedInfectiousAgents")
  Session.set("currentTemplate", "recentAgents")
Template.main.events
  'click #recentPanelTab': (event, instance) ->
    $("#recentlyMentionedInfectiousAgents").empty()
    Session.set("currentTab", "#recentlyMentionedInfectiousAgents")
    Session.set("currentTemplate", "recentAgents")
    Blaze.renderWithData(Template.recentAgents, {regionFeed: Session.get('region')}, $("#recentlyMentionedInfectiousAgents")[0])
  'click #frequentPanelTab': (event, instance) ->
    $("#frequentlyMentionedInfectiousAgents").empty()
    Session.set("currentTab", "#frequentlyMentionedInfectiousAgents")
    Session.set("currentTemplate", "frequentAgents")
    Blaze.renderWithData(Template.frequentAgents, {regionFeed: Session.get('region')}, $("#frequentlyMentionedInfectiousAgents")[0])
  'click #trendingPanelTab': (event, instance) ->
    $("#trendingInfectiousAgents").empty()
    Session.set("currentTab", "#trendingInfectiousAgents")
    Session.set("currentTemplate", "trendingAgents")
    Blaze.renderWithData(Template.trendingAgents, {regionFeed: Session.get('region')}, $("#trendingInfectiousAgents")[0])
  'click #hideAppDesc': (event, instance) ->
    $(".appDescriptionContainer").hide()
    localStorage.setItem('showAppDesc', false)
  'click #showAppDesc': (event, instance) ->
    $(".appDescriptionContainer").show()
    localStorage.setItem('showAppDesc', true)
