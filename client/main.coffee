if Meteor.isClient
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

  Template.body.helpers template_name: ->
    Session.get 'templateName'
  Template.body.events
    'click .recentlyMentionedInfectiousAgentsTableRow': ->
      #Session.set 'templateName', 'detail'
      return

  $('#recentlyMentionedInfectiousAgentsTable').on 'click-row.bs.table', (e,
    row, $element) ->
    console.log(row, $element)
    return

  $('.recentlyMentionedInfectiousAgentsTableRow').click ->
    console.log 'row was clicked'
    return

  Router.route '/', ->
    @render 'main'
    return

  Router.route '/detail/:_agentName', ->
    @render 'detail'
    $("#spinner").show()
    Meteor.call 'getRecentDescriptors', @params._agentName,
    (err, response) ->
      if err == undefined
        $("#recentDescriptorsTable > tbody").empty().append(
          Blaze.toHTMLWithData(Template.recentDescriptors, response))
      $("#spinner").hide()

    Meteor.call 'getFrequentDescriptors', @params._agentName,
    (err, response) ->
      if err == undefined
        $("#frequentDescriptorsTable > tbody").empty().append(
          Blaze.toHTMLWithData(Template.frequentDescriptors,
          response))
      $("#spinner").hide()
    return

  $(document).ready ->
    $("#spinner").show()
    Meteor.call 'getRecentlyMentionedInfectiousAgents', (err, response) ->
      if err == undefined
        for binding in response.results.bindings
          mentionDate = moment(new Date(binding.dateTime.value))
          today = moment(new Date())
          binding.days = {value: today.diff(mentionDate, 'days')}
          binding.months = {value: today.diff(mentionDate, 'months')}
          #show days or months since last mention
          if binding.days.value > 30
            binding.dm = true

        $("#recentlyMentionedInfectiousAgentsTable > tbody").empty().append(
          Blaze.toHTMLWithData(Template.recentlyMentionedInfectiousAgents,
          response.results))

      $('.recentlyMentionedInfectiousAgentsTableRow').click ->
        $("#spinner").show()
        $('.recentlyMentionedInfectiousAgentsTableRow').removeClass('info')
        $(this).addClass('info')
        window.open("/detail/" + this.dataset.agentname)
        $("#spinner").hide()
      $("#spinner").hide()

    Meteor.call 'getFrequentlyMentionedInfectiousAgents', (err, response) ->
      if err == undefined
        $("#frequentlyMentionedInfectiousAgentsTable > tbody").empty().append(
          Blaze.toHTMLWithData(Template.frequentlyMentionedInfectiousAgents,
          response.results))
    return

  Template.timeline.onRendered ->

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
