HTTP.get '/api/totalArticleCount', (err, response) =>
  if err
    toastr.error(err.message)
    return
  if response.data.results[0].articleCount == 0
    toastr.error("The datasource is empty.")
