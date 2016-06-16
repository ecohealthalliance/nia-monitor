# layout
require '../../ui/layouts/main.coffee'

# pages
require '../../ui/pages/detail.coffee'

# template helpers
require '../../ui/helpers/time.coffee'
require '../../ui/helpers/moment.coffee'
require '../../ui/helpers/plus.coffee'
require '../../ui/helpers/pluralize.coffee'

# routes
Router.route '/', ->
  @render 'main'
Router.route '/detail/:_agentName', ->
  @render 'detail', {'data': this.params}
