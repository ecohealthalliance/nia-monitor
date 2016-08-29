require './timeline.jade'
Template.timeline.onCreated ->
  @isLoading = new ReactiveVar(false)
  @timelineRange = new ReactiveVar('5years')
  @tld = new Meteor.Collection(null)
  @myBarChart = null
  @autorun =>
    agent = Router.current().getParams()._agentName
    @tld.remove({}) #find({}, reactive: false).map((d) => @tld.remove(d))
    console.log("tld", @tld.find({}, reactive: false).fetch())
    @isLoading.set(true)
    HTTP.get '/api/historicalData/' + agent + '/' + @timelineRange.get(), {
      params:
        promedFeedId: Session.get('promedFeedId') or null
    }, (err, response) =>
      @isLoading.set(false)
      if err
        toastr.error(err.message)
        return
      for row in response.data.results
        data = {timeInterval: row.timeInterval, count: row.count}
        @tld.insert(data)
  @selectedRangeRV = @data.selectedRangeRV
  @selectedElement = new ReactiveVar(null)
  @autorun =>
    element = @selectedElement.get()
    if element
      if moment(element, "YYYY").isValid()
        m = moment(element, "YYYY")
        @selectedRangeRV.set [m, m.clone().add(1, 'year')]
      else if moment(element, "MMM").isValid()
        m = moment(element, "MMM")
        # Parse months from the last year to date
        if m > moment(moment.months(moment().month()), "MMM")
          m.subtract(1, "year")
        @selectedRangeRV.set [m, m.clone().add(1, 'month')]
      else
        console.error("Unknown date format:", element)
    else
      @selectedRangeRV.set null
Template.timeline.onRendered ->
  @autorun =>
    @timelineRange.get()
    if @tld.find().count() == 0
      console.log "No data"
    else
      if @myBarChart != null
        @myBarChart.destroy()
      endDate = moment(new Date())
      baseDate = null
      xlabels = []
      counts = []
      maxCount = 0
      switch @timelineRange.get()
        when "6months"
          endMonth = endDate.month() + 1
          baseMonth = endDate.subtract(5, 'months')
          ctr = 0
          while ctr < 6
            xlabels.push moment.months(baseMonth.month())
            tdata = @tld.find({timeInterval: baseMonth.month() + 1}).fetch()
            if tdata.length == 0
              counts.push 0
            else
              counts.push tdata[0].count
            baseMonth.add(1, 'months')
            ctr++
        when "1year"
          endMonth = endDate.month() + 1
          baseMonth = endDate.subtract(11, 'months')
          ctr = 0
          while ctr < 12
            xlabels.push moment.months(baseMonth.month())
            tdata = @tld.find({timeInterval: baseMonth.month() + 1}).fetch()
            if tdata.length == 0
              counts.push 0
            else
              counts.push tdata[0].count
            baseMonth.add(1, 'months')
            ctr++
        when "5years"
          endYear = endDate.year()
          baseYear = endDate.subtract(5, 'years').year()
          while baseYear <= endYear
            tdata = @tld.find({timeInterval: baseYear}).fetch()
            if tdata.length == 0
              counts.push 0
            else
              counts.push tdata[0].count
            xlabels.push baseYear
            baseYear++
        when "all"
          baseYear = @tld.find({}, {sort: {timeInterval: 1}}).fetch()[0].timeInterval
          while baseYear <= endDate.year()
            tdata = @tld.find({timeInterval: baseYear}).fetch()
            if tdata.length == 0
              counts.push 0
            else
              counts.push tdata[0].count
            xlabels.push baseYear
            baseYear++
      selectedElement = @selectedElement.get()
      @myBarChart = new Chart(@$("canvas"),
        type: 'bar'
        data:
          labels: xlabels
          datasets: [{
            label: 'Posts'
            fill: false
            backgroundColor: xlabels.map (xlabel)->
              if selectedElement == xlabel
                'rgb(75,200,255)'
              else
                'rgb(11, 165, 255)'
            borderColor: 'rgba(0,0,0,1)'
            data: counts
          } ]
        options:
          animation:
            duration: 0
          showScale: false
          legend:
            display: false
          scales:
            yAxes: [{
              ticks:
                min: 0
                display: false
              gridLines:
                lineWidth: 0,
                color: "rgba(255,255,255,0)"
            }]
            xAxes: [{
              ticks:
                stepSize: 5
              scaleLabel:
                display: false
              gridLines:
                display: false
                lineWidth: 0
                color: "rgba(255,255,255,0)"
            }]
      )

Template.timeline.helpers
  noData: ->
    emptyResult = Template.instance().tld.find().count() == 0
    loading = Template.instance().isLoading.get()
    emptyResult or loading
  timelineRange: ->
    Template.instance().timelineRange.get()
  isLoading: ->
    Template.instance().isLoading.get()

Template.timeline.events
  'change #timelineRange': (event, template) ->
    template.timelineRange.set(template.$("#timelineRange").val())
  'click canvas': (event, template) ->
    myBarChart = template.myBarChart
    activePoints = myBarChart.getElementsAtEvent(event)
    clickedElementindex = activePoints[0]["_index"]
    label = myBarChart.data.labels[clickedElementindex]
    if template.selectedElement.get() == label
      template.selectedElement.set null
    else
      template.selectedElement.set label
