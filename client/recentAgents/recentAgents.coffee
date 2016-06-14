Template.recentAgents.onCreated ->
  @recentAgents = new Meteor.Collection(null)
  @autorun =>
    @recentAgents.find({}, reactive: false).map((d) => @recentAgents.remove(d))
    Meteor.call 'getRecentlyMentionedInfectiousAgents', (err, response) =>
      if err
        throw err
      for binding in response.results.bindings
        if binding.priorDate
          priorDate = moment(new Date(binding.priorDate.value))
          currentDate = moment(new Date(binding.currentDate.value))
          binding.days = {value: currentDate.diff(priorDate, 'days')}
          binding.months = {value: currentDate.diff(priorDate, 'months')}
          #show days or months since last mention
          if binding.days.value > 30
            binding.dm = true
        @recentAgents.insert(binding)

Template.recentAgents.helpers
  recentAgents: ->
    Template.instance().recentAgents.find()

Template.recentAgents.events
  'click .rmia-word': ->
    window.location.href = "/detail/#{this.word.value}"
