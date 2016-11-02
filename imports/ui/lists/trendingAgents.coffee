require './trendingAgents.jade'

Template.trendingAgents.onCreated ->
  @trendingAgents = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @trendingRange = new ReactiveVar("month")
  @trendingDate = new ReactiveVar(new Date())
  @autorun =>
    if Router.current().getParams()._trendingRange
      @trendingRange.set Router.current().getParams()._trendingRange
    else
      @trendingRange.set "month"
  @autorun =>
    @ready.set(false)
    @trendingAgents.find({}, reactive: false).map((d) => @trendingAgents.remove(d))
    HTTP.get '/api/trendingAgents/' + @trendingRange.get(), {
      params:
        promedFeedId: Session.get('promedFeedId') or null
        trendingDate: @trendingDate.get().toISOString()
    }, (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      filteredResults = response.data.results.filter (b)-> b.count != 0
      maxScore = _.max(filteredResults, (binding)->binding.result).result
      for binding in filteredResults
        binding.bars = _.range(Math.round(3 * binding.result / maxScore))
        # yearly trends cannot be seasonal
        binding.seasonal = @trendingRange.get() != "year" and (binding.seasonal_rate / binding.rate) > 0.75
        @trendingAgents.insert(binding)

Template.trendingAgents.onRendered ->
  @$('.date-picker').data('DateTimePicker')?.destroy()
  @$('.date-picker').datetimepicker(
    format: 'MM/DD/YYYY'
  )

Template.trendingAgents.helpers
  trendingAgents: ->
    Template.instance().trendingAgents.find()
  trendingRange: ->
    Template.instance().trendingRange.get()
  trendingDate: ->
    moment(Template.instance().trendingDate.get()).format("MM/DD/YYYY")

Template.trendingAgents.events
  'dp.change #trendingDate': (event,  instance) ->
    d = $(event.target).data('DateTimePicker')?.date().toDate()
    if d then instance.trendingDate.set d
  'click .hide-seasonal' : (event, instance) ->
    $('li span.seasonal').parent().toggle("hidden")

Template.trendingAgent.onRendered ->
  @$('[data-toggle="tooltip"]').tooltip()
