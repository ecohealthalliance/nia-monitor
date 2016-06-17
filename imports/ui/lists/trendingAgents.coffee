require './trendingAgents.jade'

Template.trendingAgents.onCreated ->
  @trendingAgents = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @trendingRange = "year"
  @autorun =>
    $(".spinner").show()
    @trendingAgents.find({}, reactive: false).map((d) => @trendingAgents.remove(d))
    date = moment(new Date())
    #TODO: remove the following date subtraction with the full dataset
    date.subtract(30, "years")
    dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    Meteor.call 'getTrendingInfectiousAgents', dateStr, (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        $(".spinner").hide()
        return
      for binding in response.results.bindings
        @trendingAgents.insert(binding)
      $(".spinner").hide()

Template.trendingAgents.helpers
  ready: ->
    Template.instance().ready.get()
  trendingAgents: ->
    Template.instance().trendingAgents.find()
  trendingRange: ->
    Template.instance().trendingRange

Template.trendingAgents.events
  'change #trendingRange': (event, template) ->
    template.ready.set(false)
    $(".spinner").show()
    template.trendingRange = $("#trendingRange").val()
    dateStr = ""
    date = moment(new Date())
    switch template.trendingRange
      when "year"
        #TODO: subtract only 1 year with the full dataset
        date.subtract(30, 'years')
      when "month"
        date.subtract(1, 'months')
      when "week"
        date.subtract(1, 'weeks')
      else
        return
    dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    template.trendingAgents.find({}, reactive: false).map((d) => template.trendingAgents.remove(d))
    Meteor.call 'getTrendingInfectiousAgents', dateStr, (err, response) =>
      template.ready.set(true)
      if err
        toastr.error(err.message)
        $(".spinner").hide()
        return
      if response.results.bindings.length == 1
        if response.results.bindings[0].count.value == "0"
          $(".spinner").hide()
          return
      for binding in response.results.bindings
        template.trendingAgents.insert(binding)
      $(".spinner").hide()
    return
