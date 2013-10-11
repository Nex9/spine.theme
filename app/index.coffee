require('lib/setup')

Spine          = require('spine')
Nex            = require('nex')

Home           = require('controllers/home')
Contact        = require('controllers/contact')

Asset          = Nex.Models.Asset
Setting        = Nex.Models.Setting

Nex.debug      = window.location.host.indexOf(':') > 0
Nex.tenant     = 'tommunro'

Spine.Model.host = if Nex.debug then "http://#{Nex.tenant}.imagoapp.com/api/v2" else "/api/v2"



class App extends Spine.Controller

  logPrefix: '(App) index: '

  constructor: ->
    super

    @models = Nex.Models

    # setup google analytics tracking
    Spine.Route.on 'navigate', (url) => _gaq.push ['_trackPageview', "#{url}"] if _gaq and not Spine.debug

    # bind window resize and scroll
    $(window).on 'scroll', @onScroll
    $(window).on 'resize', @onResize

    Spine.Route.bind 'change', @setBodyClass
    Spine.Route.bind 'change', @setLanguage

    # clear body for app
    @el.empty()

    # fetch data
    @settings      = new $.Deferred()
    Setting.bind 'refresh', => @settings.resolve()

    @manager = new Spine.Manager

    $.when(
      @settings
    ).then(
      @appReady, @errorCallback
    )

    @routes
      '/' : ->
        @home.active('/fashion')

      # '/:lang/contact' : ->
      #   @contact.active('/contact')

      # '/*page': (params) ->
      #   @page.active(params.match[0])

    Setting.fetch()

  onScroll: (e) =>
    clearTimeout(@scrollTimeout) if @scrollTimeout
    @scrollTimeout = setTimeout (=>
      $(window).trigger 'scrollstop' if @isScrolling
      @isScrolling = false
    ), 50
    return if @isScrolling
    @isScrolling = true
    $(window).trigger 'scrollstart'

  onResize: (e) =>
    clearTimeout(@resizeTimeout) if @resizeTimeout
    @resizeTimeout = setTimeout (=> $(window).trigger 'resizestop'), 200

  appReady: =>
    @log 'appReady'
    options =
      history: true
      shim: false

    @render()

    Spine.Route.setup options

    # navigate to requested url
    # @navigate(window.location.pathname)

  setLanguage: (Route, path) =>
    Nex.language = path?.match(/^\/([\w]{2})/i)?[1] or 'en'

  setBodyClass: (Route, path) =>
    path = '/home' if path is '/'
    document.body.className = (path.replace(/\//g, ' ')).trim?()

  render: ->
    # selctions
    @append @home            = new Home
    @append @contact         = new Contact

    @manager.add    \
      @home,        \
      @contact

    # @delay =>
    #   @navigate '/de/products/system/venear'
    # , 500

  goHome: =>
    @navigate '/'



module.exports = App




