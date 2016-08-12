require './timeline.jade'

Template.timeline.helpers
  timelineRange: ->
    Template.instance().timelineRange.get()
  ready: ->
    Template.instance().ready.get()

Template.timeline.events
  'change #timelineRange': (event, template) ->
    template.timelineRange.set($("#timelineRange").val())
    return
  'click #canvas': (event, template) ->
    activePoints = myLineChart.getElementsAtEvent(event)
    clickedElementindex = activePoints[0]["_index"]
    label = myLineChart.data.labels[clickedElementindex]
    #set time line filter
    localStorage.setItem('tlf', label)
    #rerender recentMentions
    $("#recentMentions").empty()
    Blaze.render(Template.recentMentions, $("#recentMentions")[0])
    return

myLineChart = null

Template.timeline.onCreated ->
  localStorage.setItem('tlf', null)
  @ready = new ReactiveVar(false)
  @timelineRange = new ReactiveVar('5years')
  @tld = new Meteor.Collection(null)
  @autorun =>
    agent = Router.current().getParams()._agentName
    @tld.find({}, reactive: false).map((d) => @tld.remove(d))
    HTTP.call 'get', '/api/historicalData/' + agent + '/' + @timelineRange.get(), (err, response) =>
      if err
        toastr.error(err.message)
        return
      if myLineChart != null
        myLineChart.destroy()
      for row in response.data.results
        data = {timeInterval: row.timeInterval, count: row.count}
        @tld.insert(data)
      endDate = moment(new Date())
      baseDate = null
      ymMax = moment(new Date()).year()
      monthNames = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
      xlabels = []
      counts = []
      maxCount = 0
      switch @timelineRange.get()
        when "6months"
          endMonth = endDate.month() + 1
          baseMonth = endDate.subtract(5, 'months')
          ctr = 0
          while ctr < 6
            xlabels.push monthNames[baseMonth.month() + 1]
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
            xlabels.push monthNames[baseMonth.month() + 1]
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
      myLineChart = new Chart($("#canvas"),
        type: 'bar'
        data:
          labels: xlabels
          datasets: [{
            label: 'Posts'
            fill: false
            lineTension: 0.1
            backgroundColor: 'rgb(11, 165, 255)'
            borderColor: 'rgba(75,192,192,1)'
            borderCapStyle: 'butt'
            borderDash: []
            borderDashOffset: 0.0
            borderJoinStyle: 'miter'
            pointBorderColor: 'rgba(75,192,192,1)'
            pointBackgroundColor: '#fff'
            pointBorderWidth: 1
            pointHoverRadius: 5
            pointHoverBackgroundColor: 'rgba(75,192,192,1)'
            pointHoverBorderColor: 'rgba(220,220,220,1)'
            pointHoverBorderWidth: 2
            pointRadius: 1
            pointHitRadius: 10
            data: counts
          } ]
        options:
          showScale: false
          legend:
            display: false
          scales:
            yAxes: [{
              ticks:
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
      $("#timeLineSpinner").hide()
