require './recentMentions.jade'

Template.recentMentions.onCreated ->
  @selectedRangeRV = @data.selectedRangeRV
  @mentions = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @sources = new Meteor.Collection(null)
  @autorun =>
    @ready.set(false)
    params = {
      promedFeedId: Session.get('promedFeedId') or null
    }
    if @selectedRangeRV.get()
      params =
        from: @selectedRangeRV.get()[0].toISOString()
        to: @selectedRangeRV.get()[1].toISOString()
    agent = Router.current().getParams()._agentName
    @mentions.remove({})
    @sources.remove({})
    HTTP.get '/api/recentMentions/' + agent, {
      params: params
    }, (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      for row in response.data.results
        if row.post
          sourceId = @sources.findOne(uri: row.post)?._id
          unless sourceId
            sourceId = @sources.insert
              uri: row.post
              postSubject: row.postSubject
              date: moment.utc(row.date)
          row.sourceId = sourceId
        @mentions.insert(row)

Template.recentMentions.helpers
  sources: ->
    Template.instance().sources.find()
  mentionsForSource: (sourceId) ->
    Template.instance().mentions.find(sourceId: sourceId)
  startDate: ->
    selectedRange = Template.instance().selectedRangeRV.get()
    if selectedRange
      moment(selectedRange[0]).format("MMM Do YYYY")
  endDate: ->
    selectedRange = Template.instance().selectedRangeRV.get()
    if selectedRange
      moment(selectedRange[1]).format("MMM Do YYYY")
  range: ->
    selectedRange = Template.instance().selectedRangeRV.get()
    if selectedRange
      moment(selectedRange[0]).format("MMM Do YYYY") +
       " - " + moment(selectedRange[1]).format("MMM Do YYYY")
Template.recentMentions.events
  'click .promed-link': (event, template) ->
    if @uri
      $('#proMedIFrame').attr('src', @uri.replace("http", "https"))
      $('#proMedURL').attr('href', @uri)
      $('#proMedURL').text(@uri)
    else
      $('#proMedIFrame').attr('src', @priorArticle.replace("http", "https"))
      $('#proMedURL').attr('href', @priorArticle)
      $('#proMedURL').text(@priorArticle)
    $('#proMedModal').modal("show")
