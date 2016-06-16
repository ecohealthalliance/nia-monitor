toastr.options =
  'closeButton': true
  'debug': false
  'newestOnTop': false
  'progressBar': false
  'positionClass': 'toast-bottom-full-width'
  'preventDuplicates': true
  'onclick': null
  'showDuration': '500'
  'hideDuration': '1000'
  'timeOut': 0
  'extendedTimeOut': 0
  'showEasing': 'swing'
  'hideEasing': 'linear'
  'showMethod': 'fadeIn'
  'hideMethod': 'fadeOut'
  'tapToDismiss': false

Meteor.toastr = (err) ->
  toastr.error(err.message)
  $(".spinner").hide()
  return
