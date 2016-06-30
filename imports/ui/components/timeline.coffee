require './timeline.jade'

Template.timeline.helpers
  ready: ->
    Template.instance().ready.get()

Template.timeline.onCreated ->
  @ready = new ReactiveVar(false)
  @tld = new Meteor.Collection(null)
  @autorun =>
    agent = Router.current().getParams()._agentName
    @tld.find({}, reactive: false).map((d) => @tld.remove(d))
    HTTP.call 'get', '/api/historicalData/' + agent, (err, response) =>
      if err
        toastr.error(err.message)
        return
      for row in response.data.results
        data = {year: row.year, count: row.count}
        @tld.insert(data)
      baseYear = @tld.find({}, {sort: {year: -1}}).fetch()[0].year
      ctryear = baseYear
      data = {}
      tdata = @tld.find().fetch()
      while ctryear > baseYear - 5
        data[ctryear] = @tld.find({year: ctryear}).fetch()
        if data[ctryear].length ==  0
          data[ctryear][0] = {year: ctryear, "count": 0}
        ctryear--
      myLineChart = new Chart($("#canvas"),
        type: 'bar'
        data:
          labels: [
            baseYear - 4
            baseYear - 3
            baseYear - 2
            baseYear - 1
            baseYear
          ]
          datasets: [{
            label: 'Articles'
            fill: false
            lineTension: 0.1
            backgroundColor: 'rgba(75,192,192,0.4)'
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
            data: [
              data[baseYear - 4][0].count
              data[baseYear - 3][0].count
              data[baseYear - 2][0].count
              data[baseYear - 1][0].count
              data[baseYear][0].count
            ]
          } ]
        options:
          legend:
            display: false
          xAxes: [ { display: true } ],
          scaleShowLabels: true,
          scales:
            yAxes: [{
              ticks:
                stepSize: 5
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
                display: true
                labelString: 'Year'
              gridLines:
                lineWidth: 0
                color: "rgba(255,255,255,0)"
            }]
      )
      $("#timeLineSpinner").hide()
