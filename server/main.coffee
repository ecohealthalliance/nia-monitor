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
castBinding = (binding)->
  result = {}
  for key, value of binding
    if value.datatype == "http://www.w3.org/2001/XMLSchema#integer"
      result[key] = parseInt(value.value)
    else
      result[key] = value.value
  result
Meteor.methods(

  'SPARQurL': () ->
    SPARQurL

  'init' : () ->
    JSON.parse

  'getRecentlyMentionedInfectiousAgents' : () ->
    query = prefixes + '''
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
                  ?currentArticle pro:date ?currentDate .
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
            ?prevArticle pro:date ?prevDate .
            FILTER(?currentDate >= ?prevDate && ?currentArticle != ?prevArticle)
          }
      }
      # Group by the items from the inner query
      GROUP BY ?resolvedTerm ?currentDate ?currentArticle ?firstMentionStart
      ORDER BY DESC(?currentDate) DESC(?currentArticle) ASC(?firstMentionStart)
      '''
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)

  'getHistoricalData': (termLabel) ->
    query = prefixes + """
      SELECT (max(?dateTime) as ?mdt)
      WHERE {
        ?phrase anno:category "diseases"
        ; anno:source_doc ?currentArticle
        ; anno:selected-text ?rawText
        ; ^dc:relation ?resolvedTerm
        .
        ?resolvedTerm rdfs:label ?termLabel .
        ?currentArticle pro:date ?dateTime
        filter(?termLabel = "#{termLabel}")
      }
      """
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )

    recentDate = (JSON.parse(response.content).results.bindings)[0].mdt.value

    baseYear = moment(recentDate).year() - 5

    # Use current year - 5 with full dataset; above query to get base year will
    # not be needed.
    # baseYear = moment(new Date()).year() - 5

    console.log baseYear

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
          FILTER(?termLabel = "#{termLabel}")
          FILTER (?dateTime > "#{baseYear}-01-01T00:00:00+00:01"^^xsd:dateTime)
    		BIND(year(?dateTime) AS ?year)
        }
        GROUP BY ?termLabel ?article ?year
        ORDER BY DESC(?dateTime)
        }
      GROUP BY ?word ?year
      """
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)

  'getFrequentlyMentionedInfectiousAgents': () ->
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
        FILTER (?dateTime > "#{baseYear}-01-01T00:00:00+00:01"^^xsd:dateTime)
      }
      GROUP BY ?resolvedTerm
      ORDER BY DESC(?count)
      LIMIT 20
      """
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)

  'getRecentMentions': (agent) ->
    query = prefixes + """
      SELECT DISTINCT ?phrase_text ?p_start ?t_start ?t_end ?source ?date
      WHERE {
          ?phrase anno:selected-text ?phrase_text
              ; anno:start ?p_start
              ; anno:end ?p_end
              ; dep:ROOT ?noop
              ; anno:contains ?target
              .
          {
              ?target anno:label "#{agent}"
          } UNION {
              ?resolvedTarget dc:relation ?target
                  ; rdfs:label "#{agent}"
          } .
          ?target anno:start ?t_start
              ; anno:end ?t_end
              ; anno:source_doc ?source
              .
          ?source pro:date ?date .
      }
      ORDER BY DESC(?date) DESC(?source) ASC(?t_start)
      LIMIT 10
      """
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content).results.bindings.map(castBinding)

  'getFrequentDescriptors' : (ia) ->
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
          	?rel rdfs:label "#{ia}"
          FILTER ( ?d_end <= ?t_start || ?t_end <= ?d_start )
          BIND(lcase(?rawSelText) as ?ranCaseSelText)
          #remove leading and trailing whitespace, and new line characters
          BIND(replace(?ranCaseSelText,'^ +| +$|\\n', '') AS ?selText)
      }
      GROUP BY ?selText
      HAVING (?count > 0)
      ORDER BY DESC(?count)
      """
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content).results.bindings.map(castBinding)
)
