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

  $('#recentlyMentionedInfectiousAgentsTable').on 'click-row.bs.table', (e,
    row, $element) ->
    console.log(row, $element)
    return

  $('.recentlyMentionedInfectiousAgentsTableRow').click ->
    console.log 'row was clicked'
    return

  $(document).ready ->
    $("#spinner").show()
    Meteor.call 'getRecentlyMentionedInfectiousAgents', (err, response) ->
      if err == undefined
        $("#recentlyMentionedInfectiousAgentsTable > tbody").empty()
        for i in response.ia
          $("#recentlyMentionedInfectiousAgentsTable > tbody:last-child")
          .append('<tr><td class="recentlyMentionedInfectiousAgentsTableRow"
          data-agentName="' + i.name + '"><h3>' + i.name + '</h3>Date: ' + i.date +
          '<br> Link: <a href="www.google.com">i.name link</a></td></tr>')

      $('.recentlyMentionedInfectiousAgentsTableRow').click ->
        $("#spinner").show()
        $('.recentlyMentionedInfectiousAgentsTableRow').removeClass('info')
        $(this).addClass('info')
        Meteor.call 'getRecentDescriptors', this.dataset.agentname,
        (err, response) ->
          if err == undefined
            $("#recentDescriptorsTable > tbody").empty()
            for i in response.rd
              $("#recentDescriptorsTable > tbody:last-child")
              .append('<tr><td class="recentDescriptorsTableRow"
              data-agentName="' + i.name + '"><h3>' + i.name + '</h3>Date: ' + i.date +
              '<br> Link: <a href="www.google.com">i.name link</a></td></tr>')
          $("#spinner").hide()

        Meteor.call 'getFrequentDescriptors', this.dataset.agentname,
        (err, response) ->
          if err == undefined
            $("#frequentDescriptorsTable > tbody").empty()
            for i in response.fd
              $("#frequentDescriptorsTable > tbody:last-child")
              .append('<tr><td>' + i.name + '</td><td>' + i.count + '</td></tr>')
          $("#spinner").hide()
        return
      $("#spinner").hide()

    Meteor.call 'getFrequentlyMentionedInfectiousAgents', (err, response) ->
      if err == undefined
        $("#frequentlyMentionedInfectiousAgentsTable > tbody").empty()
        for i in response.ia
          $("#frequentlyMentionedInfectiousAgentsTable > tbody:last-child")
          .append('<tr><td>' + i.name + '</td><td>' + i.count + '</td></tr>')

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
    return

  Template.timeline.onRendered ->
