SPARQurL = process.env.SPARQURL || 'http://localhost:3030/dataset'
prefixes = '''
prefix pro: <http://www.eha.io/types/promed/>
prefix anno: <http://www.eha.io/types/annotation_prop/>
prefix dep: <http://www.eha.io/types/annotation_prop/dep/>
prefix dc: <http://purl.org/dc/terms/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix rdf: <http://www.w3.org/2000/01/rdf-schema#>
prefix eha: <http://www.eha.io/types/>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
'''

getFrequentDescriptorsQuery = (ia) ->
  return prefixes + """
  SELECT
    ?selText
    (group_concat(DISTINCT ?article; separator = "::") AS ?articles)
    (count(DISTINCT ?article) as ?count)
  WHERE {
      ?dep_rel rdf:type anno:dependency_relation .
      VALUES ?dep_rel { dep:amod dep:nmod }
      ?parent anno:min_contains ?target
          ; ?dep_rel ?descriptor
          ; anno:source_doc ?article
          .
      ?descriptor anno:start ?d_start
          ; anno:end ?d_end
          ; anno:selected-text ?rawSelText
          ; anno:root/anno:pos ?pos
          .
      FILTER (?pos NOT IN ("X", "PUNCT"))
      ?target anno:category "diseases"
          ; anno:start ?t_start
          ; anno:end ?t_end
          ; ^dc:relation ?rel
          .
      ?rel rdfs:label "#{escape(ia)}"
      FILTER ( ?d_end <= ?t_start || ?t_end <= ?d_start )
      BIND(lcase(?rawSelText) as ?ranCaseSelText)
      #remove leading and trailing whitespace, and new line characters
      BIND(replace(?ranCaseSelText,'^ +| +$|\\n', '') AS ?selText)
  }
  GROUP BY ?selText
  HAVING (?count > 0)
  ORDER BY DESC(?count)
  """
getRecentMentionsQuery = (ia) ->
  return prefixes + """
    SELECT DISTINCT
      ?phrase_text ?p_start
      ?t_start ?t_end
      ?source ?date
    WHERE {
        ?phrase anno:selected-text ?phrase_text
        ; anno:start ?p_start
        ; anno:end ?p_end
        ; dep:ROOT ?noop
        ; anno:contains ?target
        .
        {
            ?target anno:label "#{escape(ia)}"
        } UNION {
            ?resolvedTarget dc:relation ?target
            ; rdfs:label "#{escape(ia)}"
        } .
        ?target anno:start ?t_start
        ; anno:end ?t_end
        ; anno:source_doc ?source
        .
        ?source pro:post/pro:date ?p_date .
        OPTIONAL { ?source  pro:date  ?a_date }
        BIND(coalesce(?a_date, ?p_date) AS ?date)
    }
    ORDER BY DESC(?date) DESC(?source) ASC(?t_start)
    LIMIT 10
    """
getFrequentlyMentionedAgentsQuery = ->
  return prefixes + """
    SELECT ?resolvedTerm
        (sample(?termLabel) as ?word)
        (count(DISTINCT ?article) as ?count)
    WHERE {
      ?phrase anno:category "diseases"
          ; ^dc:relation ?resolvedTerm
          ; anno:source_doc ?article
          .
      ?resolvedTerm rdfs:label ?termLabel .
    }
    GROUP BY ?resolvedTerm
    ORDER BY DESC(?count)
    LIMIT 20
    """
getRecentlyMentionedAgentsQuery = ->
  return prefixes + '''
    SELECT
        # For each of the most recently mentioned terms find the most recent
        # mention prior to the current mention.
        ?resolvedTerm ?currentDate ?currentArticle
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
            LIMIT 50
        }
        # Select the previous usages of the most recently mentioned terms
        OPTIONAL {
          ?prev_mention anno:source_doc ?prevArticle
          ; ^dc:relation ?resolvedTerm
          .
          ?prevArticle pro:post/pro:date ?p_date .
          OPTIONAL { ?prevArticle  pro:date  ?a_date }
          BIND(coalesce(?a_date, ?p_date) AS ?prevDate)
          FILTER(?currentDate >= ?prevDate && ?currentArticle != ?prevArticle)
        }
    }
    # Group by the items from the inner query
    GROUP BY ?resolvedTerm ?currentDate ?currentArticle ?firstMentionStart
    ORDER BY DESC(?currentDate) DESC(?currentArticle) ASC(?firstMentionStart)
    '''
getHistoricalDataQuery = (agent) ->
  query = prefixes + """
    SELECT (max(?date) as ?mdt)
    WHERE {
      ?phrase anno:category "diseases"
      ; anno:source_doc ?currentArticle
      ; anno:selected-text ?rawText
      ; ^dc:relation ?resolvedTerm
      .
      ?resolvedTerm rdfs:label ?termLabel .
      ?currentArticle pro:post/pro:date ?p_date .
      OPTIONAL { ?currentArticle  pro:date  ?a_date }
      BIND(coalesce(?a_date, ?p_date) AS ?date)
      filter(?termLabel = "#{escape(agent)}")
    }
    """
  response = makeRequest(query)
  recentDate = (response.results.bindings)[0].mdt.value
  baseYear = moment(recentDate).year() - 5

  query = prefixes + """
    SELECT
    (?termLabel as ?word) ?dateTime (count(?termLabel) as ?count)
    WHERE {
      ?phrase anno:category "diseases"
      ; anno:source_doc ?currentArticle
      ; anno:selected-text ?rawText
      ; ^dc:relation ?resolvedTerm
      .
      ?resolvedTerm rdfs:label ?termLabel .
      ?currentArticle pro:post/pro:date ?p_date .
      OPTIONAL { ?currentArticle  pro:date  ?a_date }
      BIND(coalesce(?a_date, ?p_date) AS ?dateTime)
      FILTER(?termLabel = "#{escape(agent)}")
      FILTER (?dateTime > "#{baseYear}-01-01T00:00:00+00:01"^^xsd:dateTime)
    }
    GROUP BY ?dateTime ?termLabel
    ORDER BY DESC(?dateTime)
    """
  return query
# Convert { value, type } objects into flat objects where the value is cast to
# the given type
castBinding = (binding) ->
  result = {}
  for key, value of binding
    if value.datatype == "http://www.w3.org/2001/XMLSchema#integer"
      result[key] = parseInt(value.value)
    else
      result[key] = value.value
  result

makeRequest = (query) ->
  try
    response = HTTP.call 'POST', "#{SPARQurL}/query?query=#{encodeURIComponent(query)}",
      headers:
        'Accept': 'application/sparql-results+json'
    JSON.parse response.content
  catch err
    if err.code
      switch err.code
        when "ECONNREFUSED"
          throw new Meteor.Error(err.code, "Unable to connect to Fuseki server.")
        else
          throw new Meteor.Error(500, "Internal Server Error")
    else
      throw new Meteor.Error(err.response.statusCode, err.response.content)

escape = (text) ->
  JSON.stringify(text).slice(1,-1)

Meteor.methods
  'getRecentlyMentionedInfectiousAgents': ->
    response = makeRequest(getRecentlyMentionedAgentsQuery())
  'getHistoricalData': (agent) ->
    response = makeRequest(getHistoricalDataQuery(agent))
  'getFrequentlyMentionedInfectiousAgents': ->
    response = makeRequest(getFrequentlyMentionedAgentsQuery())
  'getRecentMentions': (agent) ->
    response = makeRequest(getRecentMentionsQuery(agent))
    response.results.bindings.map(castBinding)
  'getFrequentDescriptors': (agent) ->
    response = makeRequest(getFrequentDescriptorsQuery(agent))
    response.results.bindings.map(castBinding)

api = new Restivus
  useDefaultAuth: true
  prettyJson: true

api.addRoute 'frequentDescriptors/:ia',
  get: ->
    response = makeRequest(getFrequentDescriptorsQuery(@urlParams.ia))
    data = {'status': 'success', 'data': response.results.bindings}
    return data
api.addRoute 'recentMentions/:ia',
  get: ->
    response = makeRequest(getRecentMentionsQuery(@urlParams.ia))
    data = {'status': 'success', 'data': response.results.bindings}
    return data
api.addRoute 'recentAgents',
  get: ->
    response = makeRequest(getRecentlyMentionedAgentsQuery())
    data = {'status': 'success', 'data': response.results.bindings}
    return data
api.addRoute 'frequentAgents',
  get: ->
    response = makeRequest(getFrequentlyMentionedAgentsQuery())
    data = {'status': 'success', 'data': response.results.bindings}
    return data
api.addRoute 'historicalData/:ia',
  get: ->
    response = makeRequest(getHistoricalDataQuery(@urlParams.ia))
    data = {'status': 'success', 'data': response.results.bindings}
    return data
