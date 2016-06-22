require './recentAgents.jade'

Template.recentAgents.onCreated ->
  @recentAgents = new Meteor.Collection(null)
  @articles = new Meteor.Collection(null)
  @autorun =>
    @recentAgents.find({}, reactive: false).map((d) => @recentAgents.remove(d))
    Meteor.call 'getRecentlyMentionedInfectiousAgents', (err, response) =>
      if err
        throw err
      for binding in response.results.bindings
        if binding.currentArticle.type is 'uri'
          articleId = @articles.findOne(uri: binding.currentArticle.value)?._id
          unless articleId
            articleId = @articles.insert
              uri: binding.currentArticle.value,
              date: moment(new Date(binding.currentDate.value))
              collapsed: false
          binding.articleId = articleId
        if binding.priorDate
          priorDate = moment(new Date(binding.priorDate.value))
          currentDate = moment(new Date(binding.currentDate.value))
          binding.days = {value: currentDate.diff(priorDate, 'days')}
          binding.months = {value: currentDate.diff(priorDate, 'months')}
          #show days or months since last mention
          if binding.days.value > 30
            binding.dm = true
        @recentAgents.insert(binding)
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
    options = { sort: { 'days.value': -1 } }
    if limit
      options.limit = 5
    Template.instance().recentAgents.find(articleId: articleId, options)

Template.recentAgents.events
  'click .more': (event, instance) ->
    instance.articles.update(@_id, { $set: { collapsed: false } })
