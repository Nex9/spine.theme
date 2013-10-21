class Home extends Nex.Page

  logPrefix: '(App) Home: '

  className:
    'home'

  constructor: ->
    super

  render: (result) ->
    @log result

module.exports = Home