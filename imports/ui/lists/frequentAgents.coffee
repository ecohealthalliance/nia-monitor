require './frequentAgents.jade'

Template.frequentAgents.onCreated ->
  @frequentAgents = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @autorun =>
    @frequentAgents.find({}, reactive: false).map((d) => @frequentAgents.remove(d))
    @ready.set(false)
    HTTP.get '/api/frequentAgents', {
      params:
        promedFeedId: Session.get('promedFeedId') or null
    }, (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      for row in response.data.results
        @frequentAgents.insert(row)

Template.frequentAgents.helpers
  frequentAgents: ->
    Template.instance().frequentAgents.find()
