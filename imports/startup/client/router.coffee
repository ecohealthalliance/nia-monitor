# layout
require '../../ui/layouts/main.coffee'

# components
require '../../ui/components/loader.jade'

# pages
require '../../ui/pages/detail.coffee'
require '../../ui/pages/descriptor.coffee'
require '../../ui/pages/datasummary.coffee'
require '../../ui/pages/about.jade'

# template helpers
require '../../ui/helpers/time.coffee'
require '../../ui/helpers/moment.coffee'
require '../../ui/helpers/plus.coffee'
require '../../ui/helpers/pluralize.coffee'
require '../../ui/helpers/misc.coffee'
require '../../ui/helpers/ready.coffee'

# modals
require '../../ui/modals/index'

# routes
Router.route '/', ->
  @render 'main'
Router.route '/detail/:_agentName', ->
  @render 'detail', { data: this.params }
Router.route '/detail/:_agentName/:_view', ->
  @render 'detail', { data: this.params }
Router.route '/descriptor/:_descriptorName', ->
  @render 'descriptor', { data: this.params }
Router.route '/descriptor/:_descriptorName/:_term', ->
  @render 'descriptor', { data: this.params }
Router.route '/datasummary', ->
  @render 'datasummary', { data: this.params }
Router.route '/about', ->
  @render 'about'
Router.route '/:_view(trending)/:_trendingRange', ->
  @render 'main', { data: this.params }
Router.route '/:_view', ->
  @render 'main', { data: this.params }
