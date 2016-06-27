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
  if _.isString text
    JSON.stringify(text).slice(1,-1)
  else
    JSON.stringify(text)

api = new Restivus
  useDefaultAuth: true
  prettyJson: true

api.addRoute 'frequentDescriptors/:term',
  get: ->
    query = prefixes + """
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
          	?rel rdfs:label "#{escape(@urlParams.term)}"
          FILTER ( ?d_end <= ?t_start || ?t_end <= ?d_start )
          BIND(lcase(?rawSelText) as ?ranCaseSelText)
          #remove leading and trailing whitespace, and new line characters
          BIND(replace(?ranCaseSelText,'^ +| +$|\\n', '') AS ?selText)
      }
      GROUP BY ?selText
      HAVING (?count > 0)
      ORDER BY DESC(?count)
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }
api.addRoute 'recentMentions/:term',
  get: ->
    query = prefixes + """
      SELECT DISTINCT
        ?phrase_text
        ?p_start ?postSubject
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
              ?target anno:label "#{escape(@urlParams.term)}"
          } UNION {
              ?resolvedTarget dc:relation ?target
              ; rdfs:label "#{escape(@urlParams.term)}"
          } .
          ?target anno:start ?t_start
          ; anno:end ?t_end
          ; anno:source_doc ?source
          .
          ?source pro:post/pro:date ?p_date
          ; pro:post/pro:subject_raw ?postSubject
          .
          OPTIONAL { ?source  pro:date  ?a_date }
          BIND(coalesce(?a_date, ?p_date) AS ?date)
      }
      ORDER BY DESC(?date) DESC(?source) ASC(?t_start)
      LIMIT 10
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }

api.addRoute 'recentAgents',
  get: ->
    query = prefixes + """
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
              LIMIT 50
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
            FILTER(?currentDate >= ?prevDate && ?currentArticle != ?prevArticle)
          }
      }
      # Group by the items from the inner query
      GROUP BY ?resolvedTerm ?currentDate ?currentArticle ?firstMentionStart
      ORDER BY DESC(?currentDate) DESC(?currentArticle) ASC(?firstMentionStart)
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }

api.addRoute 'frequentAgents',
  get: ->
    baseYear = 1991
    # Use current year - 5 with full dataset
    # baseYear = moment(new Date()).year() - 5
    query = prefixes + """
      SELECT ?resolvedTerm
          (sample(?termLabel) as ?word)
          (count(DISTINCT ?article) as ?count)
      WHERE {
        ?phrase anno:category "diseases"
        ; ^dc:relation ?resolvedTerm
        ; anno:source_doc ?article
        .
        ?article pro:date ?dateTime.
        ?resolvedTerm rdfs:label ?termLabel
        FILTER (?dateTime > "#{escape(baseYear)}-01-01T00:00:00+00:01"^^xsd:dateTime)
      }
      GROUP BY ?resolvedTerm
      ORDER BY DESC(?count)
      LIMIT 20
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }

api.addRoute 'historicalData/:term',
  get: ->
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
        filter(?termLabel = "#{escape(@urlParams.term)}")
      }
      """
    response = makeRequest(query)
    recentDate = (response.results.bindings)[0].mdt.value
    baseYear = moment(recentDate).year() - 5

    query = prefixes + """
      SELECT ?word ?year (count(?word) as ?count)
      WHERE{
        SELECT
        (?termLabel as ?word) ?year
        WHERE {
          ?phrase anno:category "diseases"
          ; anno:source_doc ?article
          ; anno:selected-text ?rawText
          ; ^dc:relation ?resolvedTerm
          .
          ?resolvedTerm rdfs:label ?termLabel .
          ?article pro:date ?dateTime
          FILTER(?termLabel = "#{escape(@urlParams.term)}")
          FILTER (?dateTime > "#{escape(baseYear)}-01-01T00:00:00+00:01"^^xsd:dateTime)
    		BIND(year(?dateTime) AS ?year)
        }
        GROUP BY ?termLabel ?article ?year
        ORDER BY DESC(?dateTime)
      }
      GROUP BY ?word ?year
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }

api.addRoute 'trendingAgents/:range',
  get: ->
    dateStr = ""
    dateStr2 = ""
    date = moment(new Date())
    date2 = moment(new Date())
    duration = "365"
    switch @urlParams.range
      when "year"
        #TODO: subtract only 4 years from date, and 1 year from date2 with the full dataset
        date.subtract(29, 'years')
        date2.subtract(30, 'years')
        duration = "365"
      when "month"
        date.subtract(1, 'months')
        date2.subtract(4, 'months')
        duration  = Math.round(moment.duration(moment(new Date()).diff(date)).asDays()).toString()
      when "week"
        date.subtract(1, 'weeks')
        date2.subtract(4, 'weeks')
        duration = "7"
      else
        return
    dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    dateStr2 = date2.format("YYYY-MM-DD") + "T00:00:00+00:01"
    query = prefixes + """
      SELECT ?resolvedTerm
        (sample(?termLabel) as ?word)
        (count(DISTINCT ?article) as ?count)
        (sample(?c2) as ?count2)
        ((?count2)/(xsd:float(#{escape(duration)}*4)) as ?rate2)
        ((?count)/(xsd:float(#{escape(duration)})) as ?rate)
        ((?rate/?rate2) AS ?result)
      WHERE {
        ?phrase anno:category "diseases"
        ; ^dc:relation ?resolvedTerm
        ; anno:source_doc ?article
        .
        ?article pro:post/pro:date ?p_date .
        OPTIONAL { ?article  pro:date  ?a_date }
        BIND(coalesce(?a_date, ?p_date) AS ?dateTime)
        ?resolvedTerm rdfs:label ?termLabel
        FILTER (?dateTime > "#{escape(dateStr)}"^^xsd:dateTime)

        {
          SELECT (count(distinct ?article2) as ?c2) ?resolvedTerm ?termLabel2
          WHERE{
            ?prev_mention anno:source_doc ?article2
            ; ^dc:relation ?resolvedTerm
            .
            ?article2 pro:post/pro:date ?p_date2 .
            OPTIONAL { ?article2  pro:date  ?a_date2 }
            BIND(coalesce(?a_date2, ?p_date2) AS ?dateTime2) .
      		  ?resolvedTerm rdfs:label ?termLabel2
            FILTER (?dateTime2 > "#{escape(dateStr2)}"^^xsd:dateTime)
           }
          GROUP BY ?resolvedTerm ?termLabel2
        }
      }
      GROUP BY ?resolvedTerm
      ORDER BY DESC(?result)
      LIMIT 20
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }
