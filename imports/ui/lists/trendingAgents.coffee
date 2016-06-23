require './trendingAgents.jade'

Template.trendingAgents.onCreated ->
  @trendingAgents = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @trendingRange = new ReactiveVar("year")
  @autorun =>
    $(".spinner").show()
    @trendingAgents.find({}, reactive: false).map((d) => @trendingAgents.remove(d))
    date = moment(new Date())
    date2 = moment(new Date())
    #TODO: subtract 4 years from date, and 1 year from date2 with the full dataset
    date.subtract(21, "years")
    date2.subtract(30, "years")
    dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    dateStr2 = date2.format("YYYY-MM-DD") + "T00:00:00+00:01"
    days = "365"
    Meteor.call 'getTrendingInfectiousAgents', dateStr, dateStr2, days, (err, response) =>
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
    Template.instance().trendingRange.get()

Template.trendingAgents.events
  'change #trendingRange': (event, template) ->
    template.ready.set(false)
    $(".spinner").show()
    template.trendingRange.set($("#trendingRange").val())
    dateStr = ""
    dateStr2 = ""
    date = moment(new Date())
    date2 = moment(new Date())
    days = "365"
    switch template.trendingRange.get()
      when "year"
        #TODO: subtract only 4 years from date, and 1 year from date2 with the full dataset
        date.subtract(29, 'years')
        date2.subtract(30, 'years')
        days = "365"
      when "month"
        date.subtract(1, 'months')
        date2.subtract(4, 'months')
        days = "30"
      when "week"
        date.subtract(1, 'weeks')
        date2.subtract(4, 'weeks')
        days = "7"
      else
        return
    dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    dateStr2 = date2.format("YYYY-MM-DD") + "T00:00:00+00:01"
    template.trendingAgents.find({}, reactive: false).map((d) => template.trendingAgents.remove(d))
    alert days
    Meteor.call 'getTrendingInfectiousAgents', dateStr, dateStr2, days, (err, response) =>
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
