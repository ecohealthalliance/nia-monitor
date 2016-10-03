require './datasummary.jade'

Template.datasummary.helpers
  totalArticleCount: ->
    Template.instance().totalArticleCount.get()
  articlesByAnnotator: ->
    Template.instance().articlesByAnnotator.find()

Template.datasummary.onCreated ->
  @ready = new ReactiveVar(false)
  @articlesByAnnotator = new Meteor.Collection(null)
  @totalArticleCount = new ReactiveVar(0)
  @autorun =>
    HTTP.get '/api/articleCountByAnnotator', (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      for binding in response.data.results
        @articlesByAnnotator.insert(binding)

    HTTP.get '/api/totalArticleCount', (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      @totalArticleCount.set(response.data.results[0].articleCount)
