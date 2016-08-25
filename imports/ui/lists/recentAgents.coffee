require './recentAgents.jade'

pp = 75

Template.recentAgents.onCreated ->
  @recentAgents = new Meteor.Collection(null)
  @posts = new Meteor.Collection(null)
  @currentPageNumber = new ReactiveVar(0)
  @isLoading = new ReactiveVar(false)
  @clear = true
  @theEnd = new ReactiveVar(false)
  order = 0
  @loadMorePosts = =>
    if @isLoading.get() then return
    pageNum = @currentPageNumber.get()
    @currentPageNumber.set(pageNum + 1)
    # @recentAgents.find({}, reactive: false).map((d) => @recentAgents.remove(d))
    @isLoading.set(true)
    @autorun =>
      Session.get("region")
      if @clear #changed the region feed
        @isLoading.set(true)
        @posts.remove({})
        @recentAgents.remove({})
      @clear = true
      HTTP.get '/api/recentAgents', {params: {page: pageNum, pp: pp}}, (err, res) =>
        @isLoading.set(false)
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
              postDate: moment(new Date(row.postDate))
              collapsed: false
              order: order++
          row.postId = postId
          if row.priorPostDate
            row.priorPostDate = new Date(row.priorPostDate)
            priorPostDate = moment(row.priorPostDate)
            postDate = moment(new Date(row.postDate))
            row.days = postDate.diff(priorPostDate, 'days')
            row.months = postDate.diff(priorPostDate, 'months')
            #show days or months since last mention
            if row.days > 30
              row.dm = true
          @recentAgents.insert(row)
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
  @loadMorePosts(false)

Template.recentAgents.helpers
  post: ->
    Template.instance().posts.find({}, {sort: {order: 1}})
  isLoading: ->
    Template.instance().isLoading.get()
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
    instance.clear = false
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
