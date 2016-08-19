require './trendingAgents.jade'

Template.trendingAgents.onCreated ->
  @trendingAgents = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @trendingRange = new ReactiveVar("year")
  @autorun =>
    @trendingAgents.find({}, reactive: false).map((d) => @trendingAgents.remove(d))
    HTTP.get '/api/trendingAgents/' + @trendingRange.get(), (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      filteredResults = response.data.results.filter (b)-> b.count != 0
      maxScore = _.max(filteredResults, (binding)->binding.result).result
      for binding in filteredResults
        binding.bars = _.range(Math.round(3 * binding.result / maxScore))
        @trendingAgents.insert(binding)

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
    template.trendingRange.set($("#trendingRange").val())
    return

Template.powerBars.onRendered ->
  @$('[data-toggle="tooltip"]').tooltip()
