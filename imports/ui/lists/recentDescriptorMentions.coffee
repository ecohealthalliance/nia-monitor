require './recentDescriptorMentions.jade'

Template.recentDescriptorMentions.onCreated ->
  @mentions = new Meteor.Collection(null)
  @sources = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @autorun =>
    @ready.set(false)
    {_descriptorName, _term} = Router.current().getParams()
    params = {
      descriptor: _descriptorName
      promedFeedId: Session.get('promedFeedId') or null
    }
    if _term
      params.term = _term
    @mentions.find({}, reactive: false).map((d) => @mentions.remove(d))
    HTTP.call 'get', '/api/recentDescriptorMentions', {
      params: params
    }, (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        $(".spinner").hide()
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
      $(".spinner").hide()

Template.recentDescriptorMentions.helpers
  sources: ->
    Template.instance().sources.find()
  mentionsForSource: (sourceId) ->
    Template.instance().mentions.find(sourceId: sourceId)

  Template.recentDescriptorMentions.events
    'click .promed-link': (event, template) ->
      if @uri != undefined
        $('#proMedIFrame').attr('src', @uri)
        $('#proMedURL').attr('href', @uri)
        $('#proMedURL').text(@uri)
        $('#proMedModal').modal('show')
