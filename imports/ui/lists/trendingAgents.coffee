require './trendingAgents.jade'

Template.trendingAgents.onCreated ->
  @trendingAgents = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @trendingRange = "year"
  @autorun =>
    $(".spinner").show()
    @trendingAgents.find({}, reactive: false).map((d) => @trendingAgents.remove(d))
    date = moment(new Date())
    date2 = moment(new Date())
    #TODO: subtract only 4 years from date, and 1 year from date2 with the full dataset
    date.subtract(30, "years")
    date2.subtract(20, "years")
    dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    dateStr2 = date2.format("YYYY-MM-DD") + "T00:00:00+00:01"
    Meteor.call 'getTrendingInfectiousAgents', dateStr, dateStr2, (err, response) =>
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
    dateStr2 = ""
    date = moment(new Date())
    date2 = moment(new Date())
    switch template.trendingRange
      when "year"
        #TODO: subtract only 4 years from date, and 1 year from date2 with the full dataset
        date.subtract(30, 'years')
        date2.subtract(29, 'years')
      when "month"
        date.subtract(4, 'months')
        date2.subtract(1, 'months')
      when "week"
        date.subtract(4, 'weeks')
        date2.subtract(1, 'weeks')
      else
        return
    dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    dateStr2 = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    template.trendingAgents.find({}, reactive: false).map((d) => template.trendingAgents.remove(d))
    Meteor.call 'getTrendingInfectiousAgents', dateStr, dateStr2, (err, response) =>
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
