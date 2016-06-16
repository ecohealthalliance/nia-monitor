require './frequentDescriptors.jade'

Template.frequentDescriptors.onCreated ->
  @frequentDescriptors = new Meteor.Collection(null)
  @ready = new ReactiveVar(false)
  @autorun =>
    $(".spinner").show()
    @frequentDescriptors.find({}, reactive: false).map((d) => @frequentDescriptors.remove(d))
    Meteor.call 'getFrequentDescriptors', this.data._agentName, (err, response) =>
      @ready.set(true)
      if err
        Meteor.toastr err
      for row in response
        @frequentDescriptors.insert(row)
      $(".spinner").hide()

Template.frequentDescriptors.helpers
  ready: ->
    Template.instance().ready.get()
  frequentDescriptors: ->
    Template.instance().frequentDescriptors.find()
