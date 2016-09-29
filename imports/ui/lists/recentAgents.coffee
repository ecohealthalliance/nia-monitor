require './recentAgents.jade'

pp = 75

Template.recentAgents.onCreated ->
  @recentAgents = new Meteor.Collection(null)
  @posts = new Meteor.Collection(null)
  @currentPageNumber = new ReactiveVar(0)
  @ready = new ReactiveVar(false)
  @theEnd = new ReactiveVar(false)
  order = 0

  @loadMorePosts = =>
    if not @ready.get() then return
    pageNum = @currentPageNumber.get()
    @currentPageNumber.set(pageNum + 1)
    # @recentAgents.find({}, reactive: false).map((d) => @recentAgents.remove(d))
    @ready.set(false)
    HTTP.get '/api/recentAgents', {
      params:
        promedFeedId: Session.get('promedFeedId')  or null
        page: pageNum
        pp: pp
    }, (err, res) =>
      @ready.set(true)
      if err
        toastr.error(err.message)
        return
      unless res.data.results.length
        @theEnd.set(true)
        return
      for row in res.data.results
        postId = @posts.findOne(uri: row.post)?._id
        unless postId
          postId = @posts.insert
            uri: row.post
            postSubject: row.postSubject
            postDate: moment.utc(row.postDate)
            collapsed: false
            order: order++
        row.postId = postId
        if row.priorPostDate
          row.priorPostDate = moment.utc(row.priorPostDate).toDate()
          postDate = moment.utc(row.postDate)
          row.days = postDate.diff(row.priorPostDate, 'days')
          row.months = postDate.diff(row.priorPostDate, 'months')
          #show days or months since last mention
          if row.days > 30
            row.dm = true
        @recentAgents.insert(row)
      # ...
      @posts.find().forEach (post) =>
        if @recentAgents.find(postId: post._id).count() > 5
          @posts.update(post._id, { $set: { collapsed: true } })

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
      @$("button.load-more-posts").click()
      done()
  }

  infiniteScroll(options)

  @autorun =>
    Session.get("promedFeedId")
    @posts.remove({})
    @recentAgents.remove({})
    @ready.set(true)
    @theEnd.set(false)
    @currentPageNumber.set(0)
    _.defer =>
      @loadMorePosts()

Template.recentAgents.helpers
  post: ->
    Template.instance().posts.find({}, {sort: {order: 1}})
  theEnd: ->
    Template.instance().theEnd.get()
  isCollapsed: (postId) ->
    Template.instance().posts.findOne(postId).collapsed
  recentAgentsForPost: (postId, limit) ->
    options = { sort: { 'priorPostDate': 1 } }
    if limit
      options.limit = 5
    Template.instance().recentAgents.find(postId: postId, options)


Template.recentAgents.events
  'click .more': (event, instance) ->
    instance.posts.update(@_id, { $set: { collapsed: false } })
  'click .load-more-posts': (event, instance) ->
    instance.loadMorePosts()
  'click .proMedLink': (event, template) ->
    if this.uri != undefined
      $('#proMedIFrame').attr('src', this.uri)
      $('#proMedURL').attr('href', this.uri)
      $('#proMedURL').text(this.uri)
    else
      $('#proMedIFrame').attr('src', this.priorPost)
      $('#proMedURL').attr('href', this.priorPost)
      $('#proMedURL').text(this.priorPost)
    $('#proMedModal').modal("show")
