class Home extends Spine.Controller
  @include Nex.Panel

  logPrefix: '(App) Home: '

  className:
    'home'

  constructor: ->
    super

    @bind 'ready', @render
    @active @getData

    @controllers = []

  render: (result) ->
    @log result

  add: (controller) ->
    @controllers.push controller
    @append controller

  deactivate: ->
    @clear()
    super

  clear: ->
    for cont in @controllers
      cont.release()
    @controllers = []
    @html ''

module.exports = Home
