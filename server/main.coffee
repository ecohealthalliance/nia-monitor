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
)
