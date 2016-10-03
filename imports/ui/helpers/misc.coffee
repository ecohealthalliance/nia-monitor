Template.registerHelper 'eq', (a, b) ->
  a == b

Template.registerHelper 'kwic', ->
  beforePhraseStart = Math.max(0, @t_start - 40 - @p_start)
  afterPhraseEnd = @t_start + 40 - @p_start
  beforePhrase = @phrase_text.slice(beforePhraseStart, @t_start - @p_start)
  keyPhrase    = @phrase_text.slice(@t_start - @p_start, @t_end - @p_start)
  afterPhrase  = @phrase_text.slice(@t_end - @p_start, afterPhraseEnd)
  if beforePhraseStart != 0
    beforePhrase = "..." + beforePhrase
  if afterPhraseEnd <= @phrase_text.length
    afterPhrase += "..."
  new Spacebars.SafeString """
    <span>#{beforePhrase}</span>
    #{keyPhrase}
    <span>#{afterPhrase}</span>
  """
