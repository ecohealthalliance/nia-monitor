# layout
require '../../ui/layouts/main.coffee'

# pages
require '../../ui/pages/detail.coffee'
require '../../ui/pages/descriptor.coffee'
require '../../ui/pages/about.jade'

# template helpers
require '../../ui/helpers/time.coffee'
require '../../ui/helpers/moment.coffee'
require '../../ui/helpers/plus.coffee'
require '../../ui/helpers/pluralize.coffee'

# routes
Router.route '/', ->
  @render 'main'
Router.route '/detail/:_agentName', ->
  @render 'detail', { data: this.params }
Router.route '/descriptor/:_descriptorName', ->
  @render 'descriptor', { data: this.params }
Router.route '/descriptor/:_descriptorName/:_term', ->
  @render 'descriptor', { data: this.params }
Router.route '/about', ->
  @render 'about'
