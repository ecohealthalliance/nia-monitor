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

myLineChart = null

Template.timeline.onCreated ->
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
        data = {year: row.year, count: row.count}
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
            tdata = @tld.find({year: baseMonth.month() + 1}).fetch()
            if tdata.length == 0
              counts.push 0
            else
              if tdata[0].count > maxCount
                maxCount = tdata[0].count
              counts.push tdata[0].count
            baseMonth.add(1, 'months')
            ctr++
        when "1year"
          endMonth = endDate.month() + 1
          baseMonth = endDate.subtract(11, 'months')
          ctr = 0
          while ctr < 12
            xlabels.push monthNames[baseMonth.month() + 1]
            tdata = @tld.find({year: baseMonth.month() + 1}).fetch()
            if tdata.length == 0
              counts.push 0
            else
              if tdata[0].count > maxCount
                maxCount = tdata[0].count
              counts.push tdata[0].count
            baseMonth.add(1, 'months')
            ctr++
        when "5years"
          endYear = endDate.year()
          baseYear = endDate.subtract(5, 'years').year()
          while baseYear <= endYear
            tdata = @tld.find({year: baseYear}).fetch()
            if tdata.length == 0
              counts.push 0
            else
              if tdata[0].count > maxCount
                maxCount = tdata[0].count
              counts.push tdata[0].count
            xlabels.push baseYear
            baseYear++
        when "all"
          baseYear = @tld.find({}, {sort: {year: 1}}).fetch()[0].year
          while baseYear <= endDate.year()
            tdata = @tld.find({year: baseYear}).fetch()
            if tdata.length == 0
              counts.push 0
            else
              if tdata[0].count > maxCount
                maxCount = tdata[0].count
              counts.push tdata[0].count
            xlabels.push baseYear
            baseYear++
      stepSize = 1
      if maxCount > 10
        stepSize = 2
      if maxCount > 25
        stepSize = 5
      if maxCount > 100
        stepSize = 10
      if maxCount > 1000
        stepSize = 100
      if maxCount > 10000
        stepSize = 1000
      myLineChart = new Chart($("#canvas"),
        type: 'bar'
        data:
          labels: xlabels
          datasets: [{
            label: 'Articles'
            fill: false
            lineTension: 0.1
            backgroundColor: 'deepskyblue'
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
          legend:
            display: false
          xAxes: [ { display: true } ],
          scaleShowLabels: true,
          scales:
            yAxes: [{
              ticks:
                stepSize: stepSize
              scaleLabel:
                display: true,
                labelString: 'Number of Articles Mentioning ' + agent
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
                lineWidth: 0
                color: "rgba(255,255,255,0)"
            }]
      )
      $("#timeLineSpinner").hide()
