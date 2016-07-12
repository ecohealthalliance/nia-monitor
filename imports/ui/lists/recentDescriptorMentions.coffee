require './recentDescriptorMentions.jade'

Template.recentDescriptorMentions.onCreated ->
  @mentions = new Meteor.Collection(null)
  @sources = new Meteor.Collection(null)
  @autorun =>
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
      if err
        toastr.error(err.message)
        $(".spinner").hide()
        return
      for row in response.data.results
        if row.source
          sourceId = @sources.findOne(uri: row.source)?._id
          unless sourceId
            sourceId = @sources.insert
              uri: row.source
              postSubject: row.postSubject
              date: moment(new Date(row.date))
          row.sourceId = sourceId
        @mentions.insert(row)
      $(".spinner").hide()

Template.recentDescriptorMentions.helpers
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