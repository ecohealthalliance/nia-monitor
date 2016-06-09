@tld = new Meteor.Collection(null)

Template.timeline.onRendered ->
  currentWord = this.data._agentName
  @autorun ->
    $("#spinner").show()
    tld.remove({})
    Meteor.call 'getHistoricalData', currentWord,
    (err, response) ->
      if err == undefined
        for binding in response.results.bindings
          binding.dateTime = moment(new Date(binding.dateTime.value)).toDate()
          tld.insert(binding)

      baseYear = new Date(tld.find({}, {sort: {dateTime: -1}}).fetch()[0].dateTime).getFullYear()
      ctryear = baseYear
      data = {}
      while ctryear > baseYear - 5
        start = moment(new Date(ctryear, 0, 1)).toDate()
        end = moment(new Date(ctryear+1, 0, 1)).toDate()
        data[ctryear] = tld.find(dateTime:
          $gte: start
          $lt: end).fetch()
        ctryear--

      Meteor.data =
      labels: [
        baseYear-4
        baseYear-3
        baseYear-2
        baseYear-1
        baseYear
      ]
      datasets: [ {
        label: currentWord + ' History'
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
          data[baseYear-4].length
          data[baseYear-3].length
          data[baseYear-2].length
          data[baseYear-1].length
          data[baseYear].length
        ]
      } ]

      myLineChart = new Chart($("#canvas"),
      type: 'line'
      data: Meteor.data
      options: xAxes: [ { display: true } ], scaleShowLabels: true, scales: {
        yAxes: [ {
          ticks: {
            stepSize: 5
              }
          scaleLabel: {
            display: true,
            labelString: '# of ProMED Articles'
          }
          gridLines: {
            lineWidth: 0,
            color: "rgba(255,255,255,0)"
            }
          }]
        xAxes: [ {
          ticks: {
            stepSize: 5
              }
          scaleLabel: {
            display: true,
            labelString: 'Year'
          }
          gridLines: {
            lineWidth: 0,
            color: "rgba(255,255,255,0)"
            }
          }]
      })
      $("#spinner").hide()
