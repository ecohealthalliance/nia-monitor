Template.registerHelper 'eq', (a, b) ->
  a == b

Template.registerHelper 'kwic', ->
  beforePhrase = @phrase_text.slice(0, @t_start - @p_start)
  keyPhrase    = @phrase_text.slice(@t_start - @p_start, @t_end - @p_start)
  afterPhrase  = @phrase_text.slice(@t_end - @p_start)
  new Spacebars.SafeString """
    <td>#{beforePhrase.replace(/\s$/, "&nbsp;").replace(/\n+/g, "<br>")}</td>
    <td><span>#{keyPhrase}</span>#{afterPhrase}</td>
  """
