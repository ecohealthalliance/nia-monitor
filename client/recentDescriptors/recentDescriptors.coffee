Template.recentDescriptors.onCreated ->
  @descriptors = new Meteor.Collection(null)
  @autorun =>
    agent = Router.current().getParams()._agentName
    console.log agent
    @descriptors.find({}, reactive: false).map((d)=> @descriptors.remove(d))
    Meteor.call 'getRecentDescriptors', (err, response) =>
      if err
        throw err
      for row in response.rd
        @descriptors.insert(row)
Template.recentDescriptors.helpers
  descriptors: ->
    Template.instance().descriptors.find()
