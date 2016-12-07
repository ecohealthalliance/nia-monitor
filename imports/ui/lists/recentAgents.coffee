require './recentAgents.jade'
recentAgentsPosts = require '/imports/data/recentAgentsPosts.coffee'
recentAgents = require '/imports/data/recentAgents.coffee'
Template.recentAgents.onCreated ->
  @startDate = new ReactiveVar(moment())
  @endDate = new ReactiveVar(moment())
  @pageEndDate = new ReactiveVar(moment())
  @loadingMorePosts = new ReactiveVar(false)
  @weeksWithNoPosts = new ReactiveVar(0)
  @loadMorePosts = =>
    if @loadingMorePosts.get() then return
    @loadingMorePosts.set(true)
    @pageEndDate.set @startDate.get()
    @startDate.set moment(@startDate.get()).subtract(2, 'weeks')
    HTTP.get '/api/recentAgents', {
      params:
        promedFeedId: Session.get('promedFeedId')  or null
        end: @pageEndDate.get().toISOString()
        start: @startDate.get().toISOString()
    }, (err, res) =>
      @loadingMorePosts.set(false)
      if err
        toastr.error(err.message)
        return
      unless res.data.results.length
        @weeksWithNoPosts.set(@weeksWithNoPosts.get() + 2)
        if @weeksWithNoPosts.get() <= 2
          @loadMorePosts()
        return
      for row in res.data.results
        postId = recentAgentsPosts.findOne(uri: row.post)?._id
        unless postId
          postId = recentAgentsPosts.insert
            uri: row.post
            postSubject: row.postSubject
            postDate: moment.utc(row.postDate)
            collapsed: false
        row.postId = postId
        if row.priorPostDate
          postDate = moment.utc(row.postDate)
          row.postDate = postDate.toDate()
          row.priorPostDate = moment.utc(row.priorPostDate).toDate()
          row.days = postDate.diff(row.priorPostDate, 'days')
          row.months = postDate.diff(row.priorPostDate, 'months')
        recentAgents.insert(row)
      # ...
      recentAgentsPosts.find().forEach (post) =>
        if recentAgents.find(postId: post._id).count() > 5
          recentAgentsPosts.update(post._id, { $set: { collapsed: true } })

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

  resetToDate = (date)=>
    recentAgentsPosts.remove({})
    recentAgents.remove({})
    @loadingMorePosts.set(false)
    @weeksWithNoPosts.set(0)
    @startDate.set(date)
    @endDate.set(date)
    @pageEndDate.set(date)
    _.defer =>
      @loadMorePosts()
  @autorun =>
    Session.get("promedFeedId")
    date = Router.current().getParams().query?.date
    if date
      resetToDate(moment(date))
    else
      resetToDate(moment())

Template.recentAgents.helpers
  post: ->
    recentAgentsPosts.find({}, {sort: {postDate: -1}})
  ready: ->
    not Template.instance().loadingMorePosts.get()
  startDate: ->
    Template.instance().startDate.get().format("MMM Do YYYY")
  endDate: ->
    Template.instance().endDate.get().format("MMM Do YYYY")
  endDateBeforeToday: ->
    Template.instance().endDate.get() < moment().set(
      hour:0
      minute:0
      second:0
    )
  theEnd: ->
    Template.instance().weeksWithNoPosts.get() > 6
  isCollapsed: (postId) ->
    recentAgentsPosts.findOne(postId).collapsed
  recentAgentsForPost: (postId, limit) ->
    options = { sort: { 'priorPostDate': 1 } }
    if limit
      options.limit = 5
    recentAgents.find(postId: postId, options)

Template.recentAgents.events
  'click .btn-show-all-ia': (event, instance) ->
    recentAgentsPosts.update(@_id, { $set: { collapsed: false } })
  'click .load-more-posts': (event, instance) ->
    instance.loadMorePosts()
  'click .promed-link': (event, template) ->
    if @uri != undefined
      $('#proMedIFrame').attr('src', @uri.replace("http", "https"))
      $('#proMedURL').attr('href', @uri)
      $('#proMedURL').text(@uri)
    else
      $('#proMedIFrame').attr('src', @priorPost.replace("http", "https"))
      $('#proMedURL').attr('href', @priorPost)
      $('#proMedURL').text(@priorPost)
    $('#proMedModal').modal("show")
