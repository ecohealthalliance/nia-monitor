Router.route '/', ->
  @render 'main'

Router.route '/detail/:_agentName', ->
  @render 'detail', {'data': this.params}
