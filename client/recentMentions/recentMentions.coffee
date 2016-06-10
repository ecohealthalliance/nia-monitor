Template.recentMentions.onCreated ->
  @mentions = new Meteor.Collection(null)
  @autorun =>
    agent = Router.current().getParams()._agentName
    console.log agent
    @mentions.find({}, reactive: false).map((d)=> @mentions.remove(d))
    Meteor.call 'getRecentMentions', agent, (err, response) =>
      if err
        throw err
      console.log response
      for row in response
        @mentions.insert(row)
Template.recentMentions.helpers
  mentions: ->
    Template.instance().mentions.find()
  kwic: ->
    new Spacebars.SafeString """
      <span>...#{@phrase_text.slice(Math.max(0, @t_start - 40 - @p_start), @t_start - @p_start)}</span>
      <span>
        <strong>#{@phrase_text.slice(@t_start - @p_start, @t_end - @p_start)}</strong>
        #{@phrase_text.slice(@t_end - @p_start, @t_start + 40 - @p_start)}...
      </span>
      """
