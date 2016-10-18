require '../lists/recentDescriptorMentions.coffee'

require './descriptor.jade'

Template.descriptor.onCreated ->
  @ready = new ReactiveVar(false)

Template.descriptor.helpers
  descriptorName: ->
    Router.current().getParams()._descriptorName
  term: ->
    Router.current().getParams()._term

Template.descriptor.events
  'click .promed-link': (event, template) ->
    if @uri != undefined
      $('#proMedIFrame').attr('src', @uri.replace("http", "https"))
      $('#proMedURL').attr('href', @uri)
      $('#proMedURL').text(@uri)
    else
      $('#proMedIFrame').attr('src', @priorPost.replace("http", "https"))
      $('#proMedURL').attr('href', @priorPost)
      $('#proMedURL').text(@priorPost)
    $('#proMedModal').modal("show")
