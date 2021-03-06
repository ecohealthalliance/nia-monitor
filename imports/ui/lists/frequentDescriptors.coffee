require './frequentDescriptors.jade'

Template.frequentDescriptors.onCreated ->
  @frequentDescriptors = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @autorun =>
    @frequentDescriptors.find({}, reactive: false).map((d) => @frequentDescriptors.remove(d))
    HTTP.get '/api/frequentDescriptors/' + this.data._agentName, {
      params:
        promedFeedId: Session.get('promedFeedId') or null
    }, (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      for row in response.data.results
        @frequentDescriptors.insert(row)

Template.frequentDescriptors.helpers
  frequentDescriptors: ->
    Template.instance().frequentDescriptors.find()
  term: ->
    Template.instance().data._agentName
  empty: ->
    Template.instance().frequentDescriptors.findOne()
