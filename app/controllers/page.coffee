class Page extends Spine.Controller
  @include Nex.Panel

  className:
    'page'

  logPrefix:
    "(App) Page: "

  constructor: ->
    super
    @tmpl404 = require('views/page404')

    @controllers = []

    @bind 'ready', @render
    @active @getData

  render: (result) ->
    return @html @tmpl404(language: Nex.language) unless result.items?.length

  add: (controller) ->
    @controllers.push(controller)
    @append(controller)

  deactivate: ->
    @clear()
    super

  clear: ->
    for cont in @controllers
      cont.release()
    @controllers = []
    # @html ''

module.exports = Page
