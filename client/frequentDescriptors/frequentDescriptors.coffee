Template.frequentDescriptors.onCreated ->
  @frequentDescriptors = new Meteor.Collection(null)
  @autorun =>
    $(".spinner").show()
    @frequentDescriptors.find({}, reactive: false).map((d) => @frequentDescriptors.remove(d))
    Meteor.call 'getFrequentDescriptors', this.data._agentName, (err, response) =>
      if err
        throw err
      for row in response.fd
        @frequentDescriptors.insert(row)
      $(".spinner").hide()

Template.frequentDescriptors.helpers
  frequentDescriptors: ->
    Template.instance().frequentDescriptors.find()
