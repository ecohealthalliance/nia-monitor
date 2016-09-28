capitalize = (s)->
  if s.length
    s[0].toUpperCase() + s.slice(1)
  else
    s

postMessageHandler = (event)->
  try
    request = JSON.parse(event.data)
  catch
    return
  if request.type == "screenCapture"
    title = "NIAM"
    url = window.location.toString()
    if window.location.pathname == "/"
      title = "Recently Mentioned Diseases"
    else if url.match(/trend/)
      title = "Trending Diseases"
    else if window.location.pathname == "/frequent"
      title = "Frequently Mentioned Diseases"
    else if url.match(/detail/)
      title = capitalize(Router.current().params._agentName + " Details")
    console.log "screenCapture starting..."
    html2canvas(document.body).then (canvas)->
      #Crop to viewport
      tempCanvas = document.createElement("canvas")
      tempCanvas.height = window.innerHeight
      tempCanvas.width = window.innerWidth
      tempCanvas.getContext("2d").drawImage(
        canvas,
        0, 0, # The top of the canvas is already cropped to the scrollY position
        window.innerWidth, window.innerHeight
        0, 0,
        window.innerWidth, window.innerHeight
      )
      console.log "screenCapture done"
      window.parent.postMessage(JSON.stringify({
        screenCapture: tempCanvas.toDataURL()
        url: url
        title: title
      }), "*")

window.addEventListener("message", postMessageHandler, false)
