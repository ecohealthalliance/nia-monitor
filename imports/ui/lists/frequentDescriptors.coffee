require './frequentDescriptors.jade'

Template.frequentDescriptors.onCreated ->
  @frequentDescriptors = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @autorun =>
    Session.get("region")
    @frequentDescriptors.find({}, reactive: false).map((d) => @frequentDescriptors.remove(d))
    HTTP.call 'get', '/api/frequentDescriptors/' + this.data._agentName, (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        $(".spinner").hide()
        return
      for row in response.data.results
        @frequentDescriptors.insert(row)

Template.frequentDescriptors.helpers
  ready: ->
    Template.instance().ready.get()
  frequentDescriptors: ->
    Template.instance().frequentDescriptors.find()
  term: ->
    Template.instance().data._agentName
