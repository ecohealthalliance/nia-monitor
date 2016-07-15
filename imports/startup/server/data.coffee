{ prefixes, makeRequest, castBinding } = require './api.coffee'
{ articles, agents } = require '../../data/collections.coffee'


Meteor.publish 'articles', (monthsToShow, skipMonths) ->
  startingDate = new Date()
  oldestDate = new Date()
  if skipMonths > 0
    startingDate.setMonth startingDate.getMonth() - skipMonths
  oldestDate.setMonth startingDate.getMonth() - monthsToShow

  startingDate.setDate 0
  oldestDate.setDate 0

  articles.find(
    {
      date: {
        $lte: startingDate,
        $gte: oldestDate
      }
    },
    {
      limit: 30
      sort: { order: 1 }
    }
  )

Meteor.publish 'recentAgentsForArticle', (articleId) ->
  agents.find({articleId: articleId})


buildQuery = (limit) ->
  prefixes + """
    SELECT
        # For each of the most recently mentioned terms find the most recent
        # mention prior to the current mention.
        ?resolvedTerm ?currentDate ?currentArticle
        (sample(?p_subject) as ?postSubject)
        (sample(?termLabel) as ?word)
        (sample(?articleRawMenions) as ?rawMentions)
        (max(?prevArticle) as ?priorArticle)
        (max(?prevDate) as ?priorDate)
    WHERE {
        # Select the most recently mentioned terms.
        # Doing this as a subquery speeds up the overall query
        # by limiting items prior mentions are found for.
        {
            SELECT
              ?resolvedTerm ?termLabel ?currentDate ?currentArticle
              (min(?start) as ?firstMentionStart)
              (group_concat(DISTINCT ?rawText; separator = "::") AS ?articleRawMenions)
            WHERE {
                ?phrase anno:category "diseases"
                ; anno:source_doc ?currentArticle
                ; anno:start ?start
                ; anno:selected-text ?rawText
                ; ^dc:relation ?resolvedTerm
                .
                ?resolvedTerm rdfs:label ?termLabel .
                ?currentArticle pro:post/pro:date ?p_date .
                OPTIONAL { ?currentArticle  pro:date  ?a_date }
                BIND(coalesce(?a_date, ?p_date) AS ?currentDate)
            }
            GROUP BY ?resolvedTerm ?termLabel ?currentDate ?currentArticle
            # Sort by date, then document, then offset within the document.
            ORDER BY DESC(?currentDate) DESC(?currentArticle) ASC(?firstMentionStart)
            LIMIT #{limit}
        }
        ?currentArticle pro:post/pro:subject_raw ?p_subject .
        # Select the previous usages of the most recently mentioned terms
        OPTIONAL {
          ?prev_mention anno:source_doc ?prevArticle
          ; ^dc:relation ?resolvedTerm
          .
          ?prevArticle pro:post/pro:date ?p_date .
          OPTIONAL { ?prevArticle  pro:date  ?a_date }
          BIND(coalesce(?a_date, ?p_date) AS ?prevDate)
          FILTER(?currentDate > ?prevDate && ?currentArticle != ?prevArticle)
        }
    }
    # Group by the items from the inner query
    GROUP BY ?resolvedTerm ?currentDate ?currentArticle ?firstMentionStart
    ORDER BY DESC(?currentDate) DESC(?currentArticle) ASC(?firstMentionStart)
    """


order = 0

# Remove all existing items on startup
articles.remove({})
agents.remove({})

console.log "Populating empty collections with data from SPARQL..."
query = buildQuery(1000)
response = makeRequest(query)
data = response.results.bindings.map(castBinding)
for row in data
  articleId = articles.findOne(uri: row.currentArticle)?._id
  unless articleId
    articleId = articles.insert
      uri: row.currentArticle
      postSubject: row.postSubject
      date: new Date(row.currentDate)
      order: order++
  row.articleId = articleId
  if row.priorDate
    row.priorDate = new Date(row.priorDate)
  agents.insert(row)
console.log "done"

# Pull in new items every X minutes
interval = 30 * 60 * 1000
Meteor.setInterval(->
  console.log "Updating cache..."
  query = buildQuery(10)
  response = makeRequest(query)
  data = response.results.bindings.map(castBinding)
  for row in data
    articleId = articles.findOne(uri: row.currentArticle)?._id
    unless articleId
      articleId = articles.insert
        uri: row.currentArticle
        postSubject: row.postSubject
        date: new Date(row.currentDate)
        order: order++
      row.articleId = articleId
      if row.priorDate
        row.priorDate = new Date(row.priorDate)
      agents.insert(row)
, interval)
