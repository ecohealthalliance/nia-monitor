require './datasummary.jade'

Template.datasummary.helpers
  ready: ->
    Template.instance().ready.get()
  articles: ->
    Template.instance().articles.find()

Template.datasummary.onCreated ->
  @ready = new ReactiveVar(false)
  @articles = new Meteor.Collection(null)
  @autorun =>
    HTTP.get '/api/articleCount', (err, response) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      for binding in response.data.results
        @articles.insert(binding)
