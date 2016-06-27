require './frequentAgents.jade'

Template.frequentAgents.onCreated ->
  @frequentAgents = new Meteor.Collection(null)
  @autorun =>
    $(".spinner").show()
    @frequentAgents.find({}, reactive: false).map((d) => @frequentAgents.remove(d))
    HTTP.call 'get', '/api/frequentAgents', (err, response) =>
      if err
        toastr.error(err.message)
        $(".spinner").hide()
        return
      for row in response.data.results
        @frequentAgents.insert(row)
      $(".spinner").hide()

Template.frequentAgents.helpers
  frequentAgents: ->
    Template.instance().frequentAgents.find()
