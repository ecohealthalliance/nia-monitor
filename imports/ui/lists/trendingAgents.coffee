require './trendingAgents.jade'
@_trendingRange = "year"

Template.trendingAgents.onCreated ->
  @trendingAgents = new Meteor.Collection(null)
  @autorun =>
    $(".spinner").show()
    @trendingAgents.find({}, reactive: false).map((d) => @trendingAgents.remove(d))
    Meteor.call 'getTrendingInfectiousAgents', (err, response) =>
      if err
        throw err
      for binding in response.results.bindings
        @trendingAgents.insert(binding)
      $(".spinner").hide()

Template.trendingAgents.helpers
  trendingAgents: ->
    Template.instance().trendingAgents.find()

Template.trendingAgents.events
  'change #trendingRange': (event) ->
    @_trendingRange = $("#trendingRange").val()
    alert @_trendingRange
    return
