require './recentMentions.jade'

Template.recentMentions.onCreated ->
  @mentions = new Meteor.Collection(null)
  @sources = new Meteor.Collection(null)
  @autorun =>
    agent = Router.current().getParams()._agentName
    @mentions.find({}, reactive: false).map((d) => @mentions.remove(d))
    HTTP.call 'get', '/api/recentMentions/' + agent, (err, response) =>
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

Template.recentMentions.helpers
  sources: ->
    Template.instance().sources.find()
  mentionsForSource: (sourceId) ->
    Template.instance().mentions.find(sourceId: sourceId)
  kwic: ->
    new Spacebars.SafeString """<span>...#{@phrase_text.slice(Math.max(0, @t_start - 40 - @p_start), @t_start - @p_start)}</span>
      <span>
          <strong>#{@phrase_text.slice(@t_start - @p_start, @t_end - @p_start)}</strong>
        #{@phrase_text.slice(@t_end - @p_start, @t_start + 40 - @p_start)}...
      </span>
      """

Template.recentMentions.events
  'click .proMedLink': (event, template) ->
    if this.uri != undefined
      $('#proMedIFrame').attr('src', this.uri)
      $('#proMedURL').attr('href', this.uri)
      $('#proMedURL').text(this.uri)
    else
      $('#proMedIFrame').attr('src', this.priorArticle)
      $('#proMedURL').attr('href', this.priorArticle)
      $('#proMedURL').text(this.priorArticle)
    $('#proMedModal').modal("show")
