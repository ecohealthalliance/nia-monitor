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
    if this.uri != undefined
      $('#proMedIFrame').attr('src', this.uri)
      $('#proMedURL').attr('href', this.uri)
      $('#proMedURL').text(this.uri)
    else
      $('#proMedIFrame').attr('src', this.priorPost)
      $('#proMedURL').attr('href', this.priorPost)
      $('#proMedURL').text(this.priorPost)
    $('#proMedModal').modal("show")
