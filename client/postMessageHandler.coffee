recentAgents = require '/imports/data/recentAgents.coffee'

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
  if request.type == "eha.dossierRequest"
    title = "NIAM"
    url = window.location.toString()
    if window.location.pathname == "/"
      csvData = recentAgents.find().map (agentMention)->
        postUrl: agentMention.post
        postDate: agentMention.postDate
        postSubject: agentMention.postSubject
        priorMentionPost: agentMention.priorPost
        priorMentionPostDate: agentMention.priorPostDate
        resolvedDOIDTerm: agentMention.resolvedTerm
        agent: agentMention.word
      if csvData.length > 0
        start = _.min(csvData.map((a)->a.postDate)).toISOString().split("T")[0]
        end = _.max(csvData.map((a)->a.postDate)).toISOString().split("T")[0]
        dataUrl = 'data:text/csv;charset=utf-8;base64,' + Base64.encode(
          #excel BOM
          "\ufeff" +
          #headers
          _.keys(csvData[0]).map(JSON.stringify).join(",") + "\n" +
          #rows
          csvData.map((r)->_.values(r).map(JSON.stringify).join(",")).join("\n")
        )
        return window.parent.postMessage(JSON.stringify(
          type: "eha.dossierTag"
          title: "Infectious agents mentioned on ProMED-mail between #{start} and #{end}"
          html: """<a href='#{dataUrl}'>Download Data CSV</a><br />
            <a target="_blank" href='#{url}'>Open NIAM</a>"""
        ))
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
      window.parent.postMessage(JSON.stringify(
        type: "eha.dossierTag"
        screenCapture: tempCanvas.toDataURL()
        url: url
        title: title
      ), event.origin)

window.addEventListener("message", postMessageHandler, false)
