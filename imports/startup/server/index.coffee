SPARQurL = process.env.SPARQURL || 'http://localhost:3030/dataset/query'
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
    response = HTTP.post SPARQurL,
      headers:
        'Accept': 'application/sparql-results+json'
      params:
        query: query
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

###
@api {get} frequentDescriptors/:term Request frequent descriptors for the term
@apiName frequentDescriptors
@apiGroup descriptors

@apiParam {String} term Infectious Agent
###
api.addRoute 'frequentDescriptors/:term',
  get: ->
    query = prefixes + """
      SELECT
        ?selText
        (count(DISTINCT ?post) as ?count)
      WHERE {
          ?dep_rel rdf:type anno:dependency_relation .
          VALUES ?dep_rel { dep:amod dep:nmod }
          ?parent anno:min_contains ?target
              ; ?dep_rel ?descriptor
              ; anno:source_doc ?source
              .
  		  ?source pro:post/pro:date ?p_date
          ; pro:post/pro:subject_raw ?postSubject
          ; pro:post ?post
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
          BIND(replace(?ranCaseSelText,'^ +| +$|\\n', '') AS ?selText)
      }
      GROUP BY ?selText
      HAVING (count(DISTINCT ?source) > 0)
      ORDER BY DESC(count(DISTINCT ?source))
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }

###
@api {get} recentMentions/:term Request recent mentions for the term
@apiName recentMentions
@apiGroup descriptors

@apiParam {String} term Infectious Agent
###
api.addRoute 'recentMentions/:term',
  get: ->
    query = prefixes + """
      SELECT DISTINCT
        ?phrase_text
        ?p_start ?postSubject
        ?t_start ?t_end
        ?source ?date
        ?post
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
          ; pro:post ?post
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

###
@api {get} recentDescriptorMentions Request descriptive phrases used for the given agent.
@apiName recentDescriptorMentions
@apiGroup agent
@apiParam {String} descriptor
@apiParam {String} [term]
###
api.addRoute 'recentDescriptorMentions',
  get: ->
    { term, descriptor } = @queryParams
    query = prefixes + """
      SELECT DISTINCT
        ?phrase_text
        ?p_start ?postSubject
        ?t_start ?t_end
        (?p_date as ?date)
		    ?post
      WHERE {
          ?phrase anno:selected-text ?phrase_text
          ; anno:start ?p_start
          ; anno:end ?p_end
          ; dep:ROOT ?noop
          ; anno:contains ?target
          .
          #{if term then """
            {
                ?target anno:label "#{escape(term)}"
            } UNION {
                ?resolvedTarget dc:relation ?target
                ; rdfs:label "#{escape(term)}"
            } .
          """ else ""}
          ?target anno:start ?t_start
          ; anno:end ?t_end
          ; anno:source_doc ?source
          ; anno:category "diseases"
          .
          ?dep_rel rdf:type anno:dependency_relation .
          VALUES ?dep_rel { dep:amod dep:nmod }
          ?parent anno:min_contains ?target
          ; ?dep_rel ?descriptor
          ; anno:source_doc ?source
          .
          ?descriptor anno:start ?d_start
          ; anno:end ?d_end
          ; anno:selected-text ?rawSelText
          .

          ?source pro:post/pro:date ?p_date
          ; pro:post/pro:subject_raw ?postSubject
          ; pro:post ?post
          .

      }
      ORDER BY DESC(?date) DESC(?post) ASC(?t_start)
      LIMIT 10
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }

###
@api {get} recentAgents Request recent Agents
@apiName recentAgents
@apiGroup agent
###
api.addRoute 'recentAgents',
  get: ->
    page = @queryParams.page
    pp = @queryParams.pp
    offset = page * pp
    query = prefixes + """
      SELECT
          # For each of the most recently mentioned terms find the most recent
          # mention prior to the current mention.
          ?resolvedTerm ?postDate ?post
          ?postSubject
          (sample(?termLabel) as ?word)
          (sample(?articleRawMenions) as ?rawMentions)
          (max(?prevPost) as ?priorPost)
          (max(?prevPostDate) as ?priorPostDate)
      WHERE {
          # Select the most recently mentioned terms.
          # Doing this as a subquery speeds up the overall query
          # by limiting items prior mentions are found for.
          {
              SELECT
                ?resolvedTerm ?termLabel ?postDate ?post ?postSubject
                (min(?start) as ?firstMentionStart)
                (group_concat(DISTINCT ?rawText; separator = "::") AS ?articleRawMenions)
              WHERE {
                  ?phrase anno:category "diseases"
                  ; anno:source_doc ?source
                  ; anno:start ?start
                  ; anno:selected-text ?rawText
                  ; ^dc:relation ?resolvedTerm
                  .
                  ?resolvedTerm rdfs:label ?termLabel .
                  ?source pro:post/pro:date ?postDate
      				; pro:post/pro:subject_raw ?postSubject.
      			  ?source pro:post ?post

              }
              GROUP BY ?resolvedTerm ?termLabel ?postDate ?post ?postSubject
              # Sort by date, then document, then offset within the document.
              ORDER BY DESC(?postDate) DESC(?post) ASC(?firstMentionStart)
              LIMIT #{pp}
              OFFSET #{offset}
          }
          # Select the previous usages of the most recently mentioned terms
          OPTIONAL {
            ?prev_mention anno:source_doc ?prevSource
            ; ^dc:relation ?resolvedTerm
            .
            ?prevSource pro:post/pro:date ?prevPostDate .
    		?prevSource pro:post ?prevPost
            FILTER(?postDate > ?prevPostDate && ?post != ?prevPost)
          }
      }
      # Group by the items from the inner query
      GROUP BY ?resolvedTerm ?postDate ?post ?postSubject ?firstMentionStart
      ORDER BY DESC(?postDate) DESC(?post) ASC(?firstMentionStart)
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }

###
@api {get} frequentAgents Request frequent agents
@apiName frequentAgents
@apiGroup agent
###
api.addRoute 'frequentAgents',
  get: ->
    baseYear = 1991
    # Use current year - 5 with full dataset
    # baseYear = moment(new Date()).year() - 5
    query = prefixes + """
      SELECT ?resolvedTerm
          (sample(?termLabel) as ?word)
          (count(DISTINCT ?post) as ?count)
      WHERE {
        ?phrase anno:category "diseases"
        ; ^dc:relation ?resolvedTerm
        ; anno:source_doc ?source
        .
  		  ?source pro:post ?post.
        ?source pro:date ?dateTime.
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
###
@api {get} historicalData/:term Request historical data for the term
@apiName historicalData
@apiGroup descriptors
@apiParam {String} term Infectious Agent
###
api.addRoute 'historicalData/:term/:range',
  get: ->
    dateStr = ""
    date = moment(new Date())
    switch @urlParams.range
      when "6months"
        date.subtract(6, 'months')
        dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
      when "1year"
        date.subtract(1, 'years')
        dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
      when "5years"
        date.subtract(5, 'years')
        dateStr = date.format("YYYY") + "-01-01T00:00:00+00:01"
    dateStr = date.format("YYYY-MM-DD") + "T00:00:00+00:01"
    query = prefixes + """
      SELECT ?word ?timeInterval (count(?word) as ?count)
      WHERE{
        SELECT
        (?termLabel as ?word) ?timeInterval
        WHERE {
          ?phrase anno:category "diseases"
          ; anno:source_doc ?source
          ; anno:selected-text ?rawText
          ; ^dc:relation ?resolvedTerm
          .
          ?resolvedTerm rdfs:label ?termLabel .
          ?source pro:post ?post.
          ?source pro:date ?dateTime
          FILTER(?termLabel = "#{escape(@urlParams.term)}")
      """
    if @urlParams.range != 'all'
      query += """
        FILTER (?dateTime > "#{escape(dateStr)}"^^xsd:dateTime)
        """
    if @urlParams.range == '6months' || @urlParams.range == '1year'
      query += """
        BIND(month(?dateTime) AS ?timeInterval)
        """
    else
      query += """
        BIND(year(?dateTime) AS ?timeInterval)
        """
    query+=
    """
      }
      GROUP BY ?termLabel ?post ?timeInterval
      ORDER BY DESC(?dateTime)
    }
    GROUP BY ?word ?timeInterval
    """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }
###
@api {get} trendingAgents/:range Request trending agents in a time range (year, month, week)
@apiName trendingAgents
@apiGroup agent
@apiParam {String} range (year, month, week)
###
api.addRoute 'trendingAgents/:range',
  get: ->
    dateStr = ""
    dateStr2 = ""
    date = moment(new Date())
    date2 = moment(new Date())
    duration = "365"
    switch @urlParams.range
      when "year"
        date.subtract(1, 'years')
        date2.subtract(4, 'years')
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
      SELECT
        ?resolvedTerm ?word
        ?count ?count2
        ?result
      WHERE {
        # There is an extra level of nesting here bc virtuoso doesn't allow
        # variables bound in select statements to be used for ordering.
        {
          SELECT ?resolvedTerm
            (sample(?termLabel) as ?word)
            (count(DISTINCT ?post) as ?count)
            (sample(?c2) as ?count2)
          WHERE {
            ?phrase anno:category "diseases"
            ; ^dc:relation ?resolvedTerm
            ; anno:source_doc ?source
            .
            ?source pro:post ?post.
            ?source pro:post/pro:date ?dateTime .

            ?resolvedTerm rdfs:label ?termLabel
            FILTER (?dateTime > "#{escape(dateStr)}"^^xsd:dateTime)
            {
              SELECT (count(distinct ?post2) as ?c2) ?resolvedTerm ?termLabel2
              WHERE {
                ?prev_mention anno:source_doc ?source2
                ; ^dc:relation ?resolvedTerm
                .
                ?source2 pro:post ?post2 .
                ?source2 pro:post/pro:date ?dateTime2 .
          		  ?resolvedTerm rdfs:label ?termLabel2
                FILTER (?dateTime2 > "#{escape(dateStr2)}"^^xsd:dateTime)
               }
              GROUP BY ?resolvedTerm ?termLabel2
            }
          }
          GROUP BY ?resolvedTerm
        }
        BIND(?count/xsd:float(#{escape(duration)}) as ?rate)
        BIND(?count2/xsd:float(#{escape(duration)}*4) as ?rate2)
        BIND(?rate - ?rate2 AS ?result)
        FILTER(?result > 0)
      }
      ORDER BY DESC(?result)
      LIMIT 50
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }
###
@api {get} postCountByAnnotator
@apiName postCountByAnnotator
@apiGroup post
###
api.addRoute 'postCountByAnnotator',
  get: ->
    query = prefixes + """
      SELECT
          ?annotator
          (count(distinct ?post) AS ?postCount)
      WHERE {
          ?article pro:post ?post .
          OPTIONAL {
              ?article anno:annotated_by ?annotator
          }
      }
      GROUP BY ?annotator
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }

###
@api {get} totalPostCount
@apiName totalPostCount
@apiGroup post
###
api.addRoute 'totalPostCount',
  get: ->
    query = prefixes + """
      SELECT
          (sum(?count) AS ?postCount)
      WHERE {
          SELECT
              ?annotator
              (count(distinct ?post) AS ?count)
          WHERE {
              ?article pro:post ?post .
              OPTIONAL {
                  ?article anno:annotated_by ?annotator
              }
          }
          GROUP BY ?annotator
      }
      """
    response = makeRequest(query)
    return {
      status: "success"
      results: response.results.bindings.map(castBinding)
    }
