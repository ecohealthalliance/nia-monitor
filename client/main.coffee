@rmia = new Meteor.Collection(null)
@fmia = new Meteor.Collection(null)

@rd = new Meteor.Collection(null)
@fd = new Meteor.Collection(null)

Template.main.onCreated ->
  @autorun ->
    $(".spinner").show()
    rmia.remove({})
    Meteor.call 'getRecentlyMentionedInfectiousAgents',
    (err, response) ->
      if err == undefined
        for binding in response.results.bindings
          priorDate = moment(new Date(binding.priorDate.value))
          currentDate = moment(new Date(binding.currentDate.value))
          binding.days = {value: currentDate.diff(priorDate, 'days')}
          binding.months = {value: currentDate.diff(priorDate, 'months')}
          #show days or months since last mention
          if binding.days.value > 30
            binding.dm = true
          rmia.insert(binding)
      $(".spinner").hide()

    fmia.remove({})
    Meteor.call 'getFrequentlyMentionedInfectiousAgents', (err, response) ->
      if err == undefined
        for binding in response.results.bindings
          fmia.insert(binding)

Template.recentlyMentionedInfectiousAgents.helpers
  rmia: ->
    return rmia.find()

Template.frequentlyMentionedInfectiousAgents.helpers
  fmia: ->
    return fmia.find()

Template.recentDescriptors.helpers
  rd: ->
    return rd.find()

Template.frequentDescriptors.helpers
  fd: ->
    return fd.find()

Template.recentlyMentionedInfectiousAgents.events
  'click .rmiaWord': ->
    window.open("/detail/" + this.word.value)

Router.route '/', ->
  @render 'main'
  return

Router.route '/detail/:_agentName', ->
  @render 'detail'

Template.detail.onRendered ->
  fd.remove({})
  Meteor.call 'getFrequentDescriptors', (err, response) ->
    if err == undefined
      for row in response.fd
        fd.insert(row)

  rd.remove({})
  Meteor.call 'getRecentDescriptors', (err, response) ->
    if err == undefined
      for row in response.rd
        rd.insert(row)

Template.timeline.onRendered ->
  Meteor.data =
  labels: [
    'January'
    'February'
    'March'
    'April'
    'May'
  ]
  datasets: [ {
    label: 'My First dataset'
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
      13
      66
      3014
      8006
      11236
    ]
  } ]

  myLineChart = new Chart($("#canvas"),
  type: 'line'
  data: Meteor.data
  options: xAxes: [ { display: false } ], scaleShowLabels: false, scales: {
    yAxes: [ {
      gridLines: {
        lineWidth: 0,
        color: "rgba(255,255,255,0)"
        }
      }]
    xAxes: [ {
      gridLines: {
        lineWidth: 0,
        color: "rgba(255,255,255,0)"
        }
      }]
  })
