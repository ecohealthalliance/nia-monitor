require './trendingAgents.jade'

Template.trendingAgents.onCreated ->
  @trendingAgents = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @trendingRange = new ReactiveVar("year")
  @autorun =>
    $(".spinner").show()
    @trendingAgents.find({}, reactive: false).map((d) => @trendingAgents.remove(d))
    Meteor.call 'getTrendingInfectiousAgents', @trendingRange.get(), (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        $(".spinner").hide()
        return
      for binding in response.results.bindings
        if binding.count.value == "0"
          continue
        @trendingAgents.insert(binding)
      $(".spinner").hide()

Template.trendingAgents.helpers
  ready: ->
    Template.instance().ready.get()
  trendingAgents: ->
    Template.instance().trendingAgents.find()
  trendingRange: ->
    Template.instance().trendingRange.get()

Template.trendingAgents.events
  'change #trendingRange': (event, template) ->
    template.ready.set(false)
    $(".spinner").show()
    template.trendingRange.set($("#trendingRange").val())
    return
