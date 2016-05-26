Meteor.startup ->

SPARQurL = 'http://10.0.2.230:3030/dataset'

Meteor.methods(
  'SPARQLquery': (query) ->
    response = HTTP.call('POST', SPARQurL + '/query?query=' + encodeURIComponent(query),
      headers:
        "Accept": "application/sparql-results+json"
    )
    return JSON.parse(response.content)

  'SPARQurL': () ->
    SPARQurL

  'init' : () ->
    JSON.parse

  'getRecentlyMentionedInfectiousAgents' : () ->
    query = 'prefix anno: <http://www.eha.io/types/annotation_prop/>
            prefix rdf: <http://www.w3.org/2000/01/rdf-schema#>
            prefix promed: <http://www.eha.io/types/promed/>

            SELECT DISTINCT ?article ?word ?dateTime
            WHERE {
             ?article promed:date ?dateTime.
             ?phrase anno:root/anno:pos "NOUN";
                 anno:root/rdf:label ?word.
             ?phrase anno:source_doc ?article;
                 }

            ORDER BY DESC(?dateTime)

            LIMIT 10'
    return Meteor.call 'SPARQLquery', query

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
    return Meteor.call 'SPARQLquery', query


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
