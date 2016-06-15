require './frequentAgents.jade'

Template.frequentAgents.onCreated ->
  @frequentAgents = new Meteor.Collection(null)
  @autorun =>
    $(".spinner").show()
    @frequentAgents.find({}, reactive: false).map((d) => @frequentAgents.remove(d))
    Meteor.call 'getFrequentlyMentionedInfectiousAgents', (err, response) =>
      if err
        Meteor.toastr err
        return
      for binding in response.results.bindings
        @frequentAgents.insert(binding)
      $(".spinner").hide()

Template.frequentAgents.helpers
  frequentAgents: ->
    Template.instance().frequentAgents.find()
