# layout
require '../../ui/layouts/main.coffee'

# pages
require '../../ui/pages/detail.coffee'

# template helpers
require '../../ui/helpers/moment.coffee'

# routes
Router.route '/', ->
  @render 'main'
Router.route '/detail/:_agentName', ->
  @render 'detail', {'data': this.params}
