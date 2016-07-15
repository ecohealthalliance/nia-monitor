require './recentAgents.jade'

{ articles, agents } = require '../../data/collections.coffee'

# Maximum amount of months to be visible at one given time
maxVisibleMonths = 3

skipMonths = new ReactiveVar(Number(sessionStorage.getItem 'skipMonths') or 0)
monthsToShow = new ReactiveVar(Number(sessionStorage.getItem 'monthsToShow') or 1)

isLoadingUp = new ReactiveVar(false)
isLoadingDown = new ReactiveVar(false)

# 0 = default, -1 = up, +1 = down
lastScrollDirection = 0

loadMoreArticlesUp = ->
  if skipMonths.get() > 0
    isLoadingUp.set(true)
    amount = skipMonths.get() - 1
    skipMonths.set(amount)
    sessionStorage.setItem('skipMonths', amount)
loadMoreArticlesDown = ->
  if monthsToShow.get() >= maxVisibleMonths
    amount = skipMonths.get() + 1
    skipMonths.set(amount)
    sessionStorage.setItem('skipMonths', amount)
  else
    amount = monthsToShow.get() + 1
    monthsToShow.set(amount)
    sessionStorage.setItem('monthsToShow', amount)
  isLoadingDown.set(true)

Template.recentAgents.onCreated ->
  mutex = false
  @autorun =>
    @subscribe 'articles', monthsToShow.get(), skipMonths.get(), ->
      isLoadingUp.set(false)
      isLoadingDown.set(false)
      if lastScrollDirection < 0
        scrollTo scrollX, 275

Template.recentAgents.onRendered ->
  prevScrollPos = window.pageYOffset
  initInfiniteScroll = (options) ->
    defaults = {
      distance: 150
      callback: (done) -> done()
    }
    options = _.extend(defaults, options)
    scroller = {
      options: options
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
    # Ignore scrolling if page is not overflowing the browser view by much
    if pageHeight - clientHeight < scroller.options.distance * 2
      return
    # Handle scrolling
    if scrollPos > prevScrollPos # scroll down
      lastScrollDirection = 1
      if pageHeight - (scrollPos + clientHeight) < scroller.options.distance
        if prevScrollPos > pageHeight - (scrollPos + clientHeight)
          console.log "down"
          scroller.updateInitiated = true
          scroller.options.callback ->
            scroller.updateInitiated = false
    else # scroll up
      lastScrollDirection = -1
      if scrollPos < scroller.options.distance
        if prevScrollPos > scroller.options.distance
          console.log "up"
          scroller.updateInitiated = true
          scroller.options.callbackUp ->
            scroller.updateInitiated = false
    prevScrollPos = scrollPos
  options = {
    distance: 250
    callback: (done) =>
      unless @mutex
        @$("button.load-more-articles-down").click()
        @mutex = true
        setTimeout(=>
          @mutex = false
        , 300)
      done()
    callbackUp: (done) =>
      unless @mutex
        @$("button.load-more-articles-up").click()
        @mutex = true
        setTimeout(=>
          @mutex = false
        , 300)
      done()
  }
  initInfiniteScroll(options)

Template.recentAgents.helpers
  articles: ->
    articles.find({}, {sort: {order: 1}})
  fromDate: ->
    startingDate = new Date()
    oldestDate = new Date()
    if skipMonths.get() > 0
      startingDate.setMonth startingDate.getMonth() - skipMonths.get()
    oldestDate.setMonth( (startingDate.getFullYear() - oldestDate.getFullYear()) * 12 )
    oldestDate.setMonth( startingDate.getMonth() - monthsToShow.get() )
    moment(oldestDate).format('MMM YYYY')
  toDate: ->
    startingDate = new Date()
    if skipMonths.get() > 0
      startingDate.setMonth startingDate.getMonth() - skipMonths.get()
    moment(startingDate).format('MMM YYYY')
  isLoadingUp: ->
    isLoadingUp.get()
  isLoadingDown: ->
    isLoadingDown.get()
  showMoreButtonUp: ->
    skipMonths.get() > 0
  showMoreButtonDown: ->
    true
  showLatestButton: ->
    skipMonths.get() > 1

Template.recentAgents.events
  'click .load-more-articles-up': (event, instance) ->
    loadMoreArticlesUp()
  'click .load-more-articles-down': (event, instance) ->
    loadMoreArticlesDown()
  'click .load-latest-articles': (event, instance) ->
    skipMonths.set(0)
    sessionStorage.setItem('skipMonths', 0)

Template.recentAgentArticle.onCreated ->
  @subscribe 'recentAgentsForArticle', @data._id
  @collapsed = new ReactiveVar true

Template.recentAgentArticle.helpers
  recentAgentsForArticle: ->
    options = { sort: { 'priorDate': 1 } }
    if Template.instance().collapsed.get()
      options.limit = 5
    agents.find(articleId: Template.instance().data._id, options)
  expandable: ->
    Template.instance().collapsed.get() && agents.find(articleId: Template.instance().data._id).count() > 5

Template.recentAgentArticle.events
  'click .more': (event, instance) ->
    instance.collapsed.set(false)
