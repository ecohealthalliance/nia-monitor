HTTP.get '/api/totalPostCount', (err, response) =>
  if err
    toastr.error(err.message)
    return
  if response.data.results[0].postCount == 0
    toastr.error("The datasource is empty.")
