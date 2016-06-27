require './recentAgents.jade'

Template.recentAgents.onCreated ->
  @recentAgents = new Meteor.Collection(null)
  @articles = new Meteor.Collection(null)
  @autorun =>
    @recentAgents.find({}, reactive: false).map((d) => @recentAgents.remove(d))
    HTTP.call 'get', '/api/recentAgents', (err, response) =>
      if err
        toastr.error(err.message)
        $(".spinner").hide()
        return
      for row in response.data.results
        articleId = @articles.findOne(uri: row.currentArticle)?._id
        unless articleId
          articleId = @articles.insert
            uri: row.currentArticle
            postSubject: row.postSubject
            date: moment(new Date(row.currentDate))
            collapsed: false
        row.articleId = articleId
        if row.priorDate
          row.priorDate = new Date(row.priorDate)
          priorDate = moment(row.priorDate)
          currentDate = moment(new Date(row.currentDate))
          row.days = currentDate.diff(priorDate, 'days')
          row.months = currentDate.diff(priorDate, 'months')
          #show days or months since last mention
          if row.days > 30
            row.dm = true
        @recentAgents.insert(row)
      # ...
      @articles.find().forEach (article) =>
        if @recentAgents.find(articleId: article._id).count() > 5
          @articles.update(article._id, { $set: { collapsed: true } })

Template.recentAgents.helpers
  articles: ->
    Template.instance().articles.find()
  isCollapsed: (articleId) ->
    Template.instance().articles.findOne(articleId).collapsed
  recentAgentsForArticle: (articleId, limit) ->
    options = { sort: { 'priorDate': 1 } }
    if limit
      options.limit = 5
    Template.instance().recentAgents.find(articleId: articleId, options)

Template.recentAgents.events
  'click .more': (event, instance) ->
    instance.articles.update(@_id, { $set: { collapsed: false } })
