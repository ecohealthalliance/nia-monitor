require './recentAgents.jade'

{ articles, agents } = require '../../data/collections.coffee'

pp = 75

amountToShow = new ReactiveVar(pp)
isLoading = new ReactiveVar(false)
theEnd = new ReactiveVar(false)

loadMoreArticles = ->
  unless theEnd.get()
    amountToShow.set(amountToShow.get() + pp)

Template.recentAgents.onCreated ->
  @autorun =>
    isLoading.set(true)
    @subscribe 'articles', amountToShow.get(), ->
      isLoading.set(false)

Template.recentAgents.onRendered ->
  prevScrollPos = window.pageYOffset
  infiniteScroll = (options) ->
    defaults = {
      distance: 150 # pixels
      callback: (done) -> done()
    }
    options = _.extend(defaults, options)
    scroller = {
      options: options,
      updateInitiated: false
    }
    window.onscroll = (event) ->
      handleScroll(scroller, event)
    document.ontouchmove = (event) ->
      handleScroll(scroller, event)
  handleScroll = (scroller, event) ->
    if scroller.updateInitiated
      return
    scrollPos = window.pageYOffset
    if scrollPos == prevScrollPos
      return
    pageHeight = document.documentElement.scrollHeight
    clientHeight = document.documentElement.clientHeight
    if pageHeight - (scrollPos + clientHeight) < scroller.options.distance
      scroller.updateInitiated = true
      scroller.options.callback ->
        scroller.updateInitiated = false
    prevScrollPos = scrollPos
  options = {
    distance: 50
    callback: (done) =>
      @$("button.load-more-articles").click()
      done()
  }
  infiniteScroll(options)
  loadMoreArticles()

Template.recentAgents.helpers
  articles: ->
    articles.find({}, {sort: {order: 1}})
  isLoading: ->
    isLoading.get()
  theEnd: ->
    theEnd.get()

Template.recentAgents.events
  'click .load-more-articles': (event, instance) ->
    loadMoreArticles()

Template.recentAgentArticle.onCreated ->
  @subscribe 'recentAgentsForArticle', @data._id
  @collapsed = new ReactiveVar true

Template.recentAgentArticle.helpers
  recentAgentsForArticle: ->
    options = { sort: { 'priorDate': 1 } }
    if Template.instance().collapsed.get()
      options.limit = 5
    agents.find(articleId: Template.instance().data._id, options)
  showMoreButton: ->
    Template.instance().collapsed.get() && agents.find(articleId: Template.instance().data._id).count() > 5

Template.recentAgentArticle.events
  'click .more': (event, instance) ->
    instance.collapsed.set(false)
