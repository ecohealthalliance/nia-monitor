require './frequentDescriptors.jade'

Template.frequentDescriptors.onCreated ->
  @frequentDescriptors = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @autorun =>
    $(".spinner").show()
    @frequentDescriptors.find({}, reactive: false).map((d) => @frequentDescriptors.remove(d))
    HTTP.call 'get', '/api/frequentDescriptors/'+this.data._agentName, (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        $(".spinner").hide()
        return
      response = JSON.parse response.content
      for row in response.data
        @frequentDescriptors.insert(row)
      $(".spinner").hide()

Template.frequentDescriptors.helpers
  ready: ->
    Template.instance().ready.get()
  frequentDescriptors: ->
    Template.instance().frequentDescriptors.find()
