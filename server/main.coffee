SPARQurL = 'http://10.0.2.240:3030/dataset'

Meteor.methods(

  'SPARQurL': () ->
    SPARQurL

  'init' : () ->
    JSON.parse

  'getRecentlyMentionedInfectiousAgents' : () ->
    query = 'prefix xsd: <http://www.w3.org/2001/XMLSchema#>
            prefix anno: <http://www.eha.io/types/annotation_prop/>
            prefix rdf: <http://www.w3.org/2000/01/rdf-schema#>
            prefix promed: <http://www.eha.io/types/promed/>

            SELECT (max(?article) as ?currentArticle) (max(?dateTime) as ?currentDate) ?word (max(?article2) as ?priorArticle) (max(?dateTime2) as ?priorDate)
            WHERE {
              ?article promed:date ?dateTime.
              ?phrase anno:root/anno:pos "NOUN";
                               anno:root/rdf:label ?word.
              ?phrase anno:source_doc ?article.

              ?article2 promed:date ?dateTime2.
              ?phrase2 anno:root/anno:pos "NOUN";
                               anno:root/rdf:label ?word2.
              ?phrase2 anno:source_doc ?article2;

              filter(?dateTime > ?dateTime2 && ?article != ?article2 && ?word = ?word2)
            }
            GROUP BY ?word ?word2

            ORDER BY DESC(?currentDate) DESC(?priorDate)

            LIMIT 10'
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
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
