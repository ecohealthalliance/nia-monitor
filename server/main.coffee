Meteor.startup ->

SPARQurL = process.env.SPARQurL

Meteor.methods(
  #stub for data retrieval from SPARQL request.
  'termSearch' : (query, options) ->
    options ?= {}
    if @userId
      response = HTTP.post(
        "#{SPARQurL}/search",
          data:
            query: query,
            options: options
      )
      JSON.parse(response.content)

  'SPARQurL': () ->
    SPARQurL

  'init' : () ->
    JSON.parse

  'getRecentlyMentionedInfectiousAgents' : () ->
    Meteor._sleepForMs(5000)
    ia = {"ia":[
      {"name":"Zika", "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Smallpox", "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Yellow Fever", "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Cholera", "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Spanish Flu", "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Polio", "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"},
      {"name":"Pertussis", "date":"11/11/2021", "link":"http://www.google.com", "linkName":"google"}
      ]}
    return ia

  'getFrequentlyMentionedInfectiousAgents' : () ->
    Meteor._sleepForMs(5000)
    ia = {"ia":[
      {"name":"Zika", "count":"572"},
      {"name":"Spanish Flu", "count":"541"},
      {"name":"Smallpox", "count":"422"},
      {"name":"Pertussis", "count":"129"},
      {"name":"Yellow Fever", "count":"45"},
      {"name":"Polio", "count":"23"},
      {"name":"Cholera", "count":"6"}
      ]}
    return ia

  'getRecentDescriptors' : (ia) ->
    Meteor._sleepForMs(5000)
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
    Meteor._sleepForMs(5000)
    #get frequent descriptors for infectious agent (ia)
    fd = {"fd":[
      {"name":"Antibiotic-resistant"+ia, "count":"572"},
      {"name":"carbapenemases-producing"+ia, "count":"541"}
      ]}
    return fd
)
