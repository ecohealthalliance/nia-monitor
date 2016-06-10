SPARQurL = process.env.SPARQURL || 'http://localhost:3030/dataset'

Meteor.methods(

  'SPARQurL': () ->
    SPARQurL

  'init' : () ->
    JSON.parse

  'getRecentlyMentionedInfectiousAgents' : () ->
    query = '''
      prefix xsd: <http://www.w3.org/2001/XMLSchema#>
      prefix anno: <http://www.eha.io/types/annotation_prop/>
      prefix rdf: <http://www.w3.org/2000/01/rdf-schema#>
      prefix promed: <http://www.eha.io/types/promed/>
      prefix dc: <http://purl.org/dc/terms/>
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
                  ?resolvedTerm rdf:label ?termLabel .
                  ?currentArticle promed:date ?currentDate .
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
            ?prevArticle promed:date ?prevDate .
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
    console.log response.content
    return JSON.parse(response.content)

  'gitHistoricalData': (word) ->
    query = 'prefix xsd: <http://www.w3.org/2001/XMLSchema#>
            prefix anno: <http://www.eha.io/types/annotation_prop/>
            prefix rdf: <http://www.w3.org/2000/01/rdf-schema#>
            prefix promed: <http://www.eha.io/types/promed/>

            SELECT ?word ?dateTime (count(?word) as ?count)
            WHERE {
              ?article promed:date ?dateTime.
              ?phrase anno:root/anno:pos "NOUN";
                               anno:root/rdf:label ?word.
              ?phrase anno:source_doc ?article

              filter(?word = '+ word +')
            }
            GROUP BY ?dateTime ?word
            ORDER BY DESC(?dateTime)'
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)


  'getFrequentlyMentionedInfectiousAgents': () ->
    query = "prefix anno: <http://www.eha.io/types/annotation_prop/>
            prefix dep: <http://www.eha.io/types/annotation_prop/dep/>
            prefix rdf: <http://www.w3.org/2000/01/rdf-schema#>
            SELECT ?word
                (count(?s) as ?count)
            WHERE {
                ?s anno:root ?r .
                ?r anno:pos 'NOUN' ;
                   rdf:label ?word .
            }
            GROUP BY ?word
            ORDER BY DESC(?count)
            LIMIT 10
        "
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)


  'getRecentDescriptors': (ia) ->
    #get recent descriptor for infectious agent (ia)
    rd = {"rd":[
      {"name":"Antibiotic-resistant"+ia, "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"carbapenemases-producing"+ia, "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Descriptor 1"+ia, "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Descriptor 2"+ia, "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Descriptor 3"+ia, "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Descriptor 4"+ia, "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Descriptor 5"+ia, "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Descriptor 6"+ia, "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      ]}
    return rd

  'getFrequentDescriptors' : (ia) ->
    #get frequent descriptors for infectious agent (ia)
    fd = {"fd":[
      {"name":"Antibiotic-resistant"+ia, "count":"572"},
      {"name":"carbapenemases-producing"+ia, "count":"541"}
      ]}
    return fd
)
