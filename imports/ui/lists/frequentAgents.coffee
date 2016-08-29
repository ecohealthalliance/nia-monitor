require './frequentAgents.jade'

Template.frequentAgents.onCreated ->
  @frequentAgents = new Meteor.Collection(null)
  @isLoading = new ReactiveVar(false)
  @autorun =>
    @frequentAgents.find({}, reactive: false).map((d) => @frequentAgents.remove(d))
    @isLoading.set(true)
    HTTP.get '/api/frequentAgents', {
      params:
        promedFeedId: Session.get('promedFeedId') or null
    }, (err, response) =>
      @isLoading.set(false)
      if err
        toastr.error(err.message)
        return
      for row in response.data.results
        @frequentAgents.insert(row)

Template.frequentAgents.helpers
  frequentAgents: ->
    Template.instance().frequentAgents.find()
  isLoading: ->
    Template.instance().isLoading.get()
