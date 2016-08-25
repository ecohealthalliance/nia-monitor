require './frequentAgents.jade'

Template.frequentAgents.onCreated ->
  @frequentAgents = new Meteor.Collection(null)
  @isLoading = new ReactiveVar(false)
  @autorun =>
    Session.get("region")
    @frequentAgents.find({}, reactive: false).map((d) => @frequentAgents.remove(d))
    @isLoading.set(true)
    HTTP.call 'get', '/api/frequentAgents', (err, response) =>
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
