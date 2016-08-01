require './datasummary.jade'

Template.datasummary.helpers
  ready: ->
    Template.instance().ready.get()
  totalPostCount: ->
    Template.instance().totalPostCount.get()
  postsByAnnotator: ->
    Template.instance().postsByAnnotator.find()

Template.datasummary.onCreated ->
  @ready = new ReactiveVar(false)
  @postsByAnnotator = new Meteor.Collection(null)
  @totalPostCount = new ReactiveVar(0)
  @autorun =>
    HTTP.get '/api/postCountByAnnotator', (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      for binding in response.data.results
        @postsByAnnotator.insert(binding)

    HTTP.get '/api/totalPostCount', (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      @totalPostCount.set(response.data.results[0].postCount)
