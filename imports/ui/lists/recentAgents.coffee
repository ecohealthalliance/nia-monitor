require './recentAgents.jade'

pp = 75

Template.recentAgents.onCreated ->
  @recentAgents = new Meteor.Collection(null)
  @articles = new Meteor.Collection(null)
  @currentPageNumber = new ReactiveVar(0)
  @isLoading = new ReactiveVar(false)
  @theEnd = new ReactiveVar(false)
  order = 0
  @loadMoreArticles = =>
    if @isLoading.get() then return
    pageNum = @currentPageNumber.get()
    @currentPageNumber.set(pageNum + 1)
    # @recentAgents.find({}, reactive: false).map((d) => @recentAgents.remove(d))
    @isLoading.set(true)
    HTTP.get '/api/recentAgents', {params: {page: pageNum, pp: pp}}, (err, res) =>
      @isLoading.set(false)
      if err
        toastr.error(err.message)
        return
      unless res.data.results.length
        @theEnd.set(true)
        return
      for row in res.data.results
        postId = @articles.findOne(uri: row.post)?._id
        unless postId
          postId = @articles.insert
            uri: row.post
            postSubject: row.postSubject
            date: moment(new Date(row.postDate))
            collapsed: false
            order: order++
        row.postId = postId
        if row.priorPostDate
          row.priorDate = new Date(row.priorPostDate)
          priorDate = moment(row.priorPostDate)
          currentDate = moment(new Date(row.postDate))
          row.days = postDate.diff(priorPostDate, 'days')
          row.months = postDate.diff(priorPostDate, 'months')
          #show days or months since last mention
          if row.days > 30
            row.dm = true
        @recentAgents.insert(row)
      # ...
      @articles.find().forEach (article) =>
        if @recentAgents.find(postId: article._id).count() > 5
          @articles.update(article._id, { $set: { collapsed: true } })


Template.recentAgents.onRendered ->
  prevScrollPos = window.pageYOffset

  infiniteScroll = (options) ->
    defaults = {
      distance: 100
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
  @loadMoreArticles()

Template.recentAgents.helpers
  post: ->
    Template.instance().articles.find({}, {sort: {order: 1}})
  isLoading: ->
    Template.instance().isLoading.get()
  theEnd: ->
    Template.instance().theEnd.get()
  isCollapsed: (postId) ->
    Template.instance().articles.findOne(postId).collapsed
  recentAgentsForPost: (postId, limit) ->
    options = { sort: { 'priorDate': 1 } }
    if limit
      options.limit = 5
    Template.instance().recentAgents.find(postId: postId, options)


Template.recentAgents.events
  'click .more': (event, instance) ->
    instance.articles.update(@_id, { $set: { collapsed: false } })
  'click .load-more-articles': (event, instance) ->
    instance.loadMoreArticles()
  'click .proMedLink': (event, template) ->
    if this.uri != undefined
      $('#proMedIFrame').attr('src', this.uri)
      $('#proMedURL').attr('href', this.uri)
      $('#proMedURL').text(this.uri)
    else
      $('#proMedIFrame').attr('src', this.priorArticle)
      $('#proMedURL').attr('href', this.priorArticle)
      $('#proMedURL').text(this.priorArticle)
    $('#proMedModal').modal("show")
