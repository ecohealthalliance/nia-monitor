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
              date: moment(new Date(row.date))
          row.sourceId = sourceId
        @mentions.insert(row)
      $(".spinner").hide()

Template.recentDescriptorMentions.helpers
  ready: ->
    Template.instance().ready.get()
  sources: ->
    Template.instance().sources.find()
  mentionsForSource: (sourceId) ->
    Template.instance().mentions.find(sourceId: sourceId)
  kwic: ->
    new Spacebars.SafeString """
      <span>...#{@phrase_text.slice(Math.max(0, @t_start - 40 - @p_start), @t_start - @p_start)}</span>
      <span>
        <strong>#{@phrase_text.slice(@t_start - @p_start, @t_end - @p_start)}</strong>
        #{@phrase_text.slice(@t_end - @p_start, @t_start + 40 - @p_start)}...
      </span>
      """

  Template.recentDescriptorMentions.events
    'click .proMedLink': (event, template) ->
      if this.uri != undefined
        $('#proMedIFrame').attr('src', this.uri)
        $('#proMedURL').attr('href', this.uri)
        $('#proMedURL').text(this.uri)
        $('#proMedModal').modal("show")
