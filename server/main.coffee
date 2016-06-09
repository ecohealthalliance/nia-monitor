SPARQurL = process.env.SPARQURL || 'http://localhost:3030/dataset'
prefixes = '''
prefix pro: <http://www.eha.io/types/promed/>
prefix anno: <http://www.eha.io/types/annotation_prop/>
prefix dep: <http://www.eha.io/types/annotation_prop/dep/>
prefix dc: <http://purl.org/dc/terms/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix eha: <http://www.eha.io/types/>
'''
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
          ?word ?currentDate ?currentArticle
          (max(?prevArticle) as ?priorArticle)
          (max(?prevDate) as ?priorDate)
      WHERE {
          # Select the most recently mentioned terms.
          # Doing this as a subquery speeds up the overall query
          # by limiting items prior mentions are found for.
          {
              SELECT ?word ?currentDate ?currentArticle
              WHERE {
                  ?phrase anno:root/anno:pos "NOUN"
                      ; anno:root/rdfs:label ?word
                      ; anno:source_doc ?currentArticle
                      ; anno:start ?start
                      .
                  ?currentArticle pro:date ?currentDate .
              }
              # Sort by date, then document, then offset within the document.
              ORDER BY DESC(?currentDate) DESC(?currentArticle) ASC(?start)
              LIMIT 20
          }
          # Select the previous usages of the most recently mentioned terms
          ?prev_mention anno:root/anno:pos "NOUN"
              ; anno:root/rdfs:label ?word
              ; anno:source_doc ?prevArticle
              .
          ?prevArticle pro:date ?prevDate .
          FILTER(?currentDate >= ?prevDate && ?currentArticle != ?prevArticle)
      }
      # Group by the items from the inner query
      GROUP BY ?word ?currentDate ?currentArticle
      '''
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)

  'gitHistoricalData': (word) ->
    query = prefixes + """
      SELECT ?word ?dateTime (count(?word) as ?count)
      WHERE {
        ?article pro:date ?dateTime.
        ?phrase anno:root/anno:pos "NOUN";
                         anno:root/rdfs:label ?word.
        ?phrase anno:source_doc ?article

        filter(?word = "#{word}")
      }
      GROUP BY ?dateTime ?word
      ORDER BY DESC(?dateTime)
      """
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)


  'getFrequentlyMentionedInfectiousAgents': () ->
    query = prefixes + '''
      SELECT ?word
          (count(?s) as ?count)
      WHERE {
          ?s anno:root ?r .
          ?r anno:pos 'NOUN' ;
             rdfs:label ?word .
      }
      GROUP BY ?word
      ORDER BY DESC(?count)
      LIMIT 10
      '''
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)

  'getRecentMentions': (agent) ->
    query = prefixes + """
      SELECT ?phrase_text ?p_start ?t_start ?t_end ?source ?date
      WHERE {
          ?phrase anno:selected-text ?phrase_text
              ; anno:start ?p_start
              ; anno:end ?p_end
              ; dep:ROOT ?noop
              .
          {
              ?target anno:label "#{agent}"
          } UNION {
              ?resolvedTarget dc:relation ?target
                  ; rdfs:label "#{agent}"
          } .
          ?target anno:start ?t_start
              ; anno:end ?t_end
              .
          ?phrase anno:source_doc ?source .
          ?target anno:source_doc ?source .
          ?source pro:date ?date .
          FILTER ( ?t_start >= ?p_start && ?t_end <= ?p_end )
      }
      ORDER BY DESC(?date) DESC(?source) ASC(?t_start)
      LIMIT 10
      """
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content).results.bindings.map (binding)->
      result = {}
      for key, value of binding
        if value.datatype == "http://www.w3.org/2001/XMLSchema#integer"
          result[key] = parseInt(value.value)
        else
          result[key] = value.value
      result

  'getFrequentDescriptors' : (ia) ->
    #get frequent descriptors for infectious agent (ia)
    fd = {"fd":[
      {"name":"Antibiotic-resistant"+ia, "count":"572"},
      {"name":"carbapenemases-producing"+ia, "count":"541"}
      ]}
    return fd
)
