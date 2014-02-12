require('lib/setup')
_ = require('underscore')

Spine          = require('spine')
Nex            = require('nex')

Home           = require('controllers/home')

Asset          = Nex.Models.Asset
Setting        = Nex.Models.Setting

Nex.debug      = window.location.host.indexOf(':') > 0
Nex.tenant     = 'demo'

Spine.Model.host = if (Nex.debug and Nex.data is 'online') then "http://#{Nex.tenant}.imagoapp.com/api/v2" else "/api/v2"



class App extends Spine.Controller

  logPrefix: '(App) index: '

  events:
    'tap a' : 'onNavigate'

  constructor: ->
    super

    @models = Nex.Models

    # setup google analytics tracking
    Spine.Route.on 'navigate', (url) => _gaq.push ['_trackPageview', "#{url}"] if _gaq and not Spine.debug

    # bind window resize and scroll
    @window = $(window)

    @window.on 'resize', @onResizeStart
    @window.on 'resize', _.debounce (=> @window.trigger 'resizestop'),  200
    @window.on 'resize', _.throttle (=> @window.trigger 'resizelimit'), 150

    @window.on 'scroll', @onScrollStart
    @window.on 'scroll', _.debounce (=> @window.trigger 'scrollstop'),  200
    @window.on 'scroll', _.throttle (=> @window.trigger 'scrolllimit'), 150

    @window.on 'mousewheel', @onMouseWheelStart
    @window.on 'mousewheel', _.debounce (=> @window.trigger 'mousewheelstop'),  200
    @window.on 'mousewheel', _.throttle (=> @window.trigger 'mousewheellimit'), 150

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
        @home.active('/')

      # '/:lang/contact' : ->
      #   @contact.active('/contact')

      # '/*page': (params) ->
      #   @page.active(params.match[0])

    Setting.fetch()

  onResizeStart: (e) =>
    return if @resizeing
    @window.trigger 'resizestart'
    @resizeing = true
    @window.one 'resizestop', => @resizeing = false

  onScrollStart: (e) =>
    return if @scrolling
    @window.trigger 'scrollstart'
    @scrolling = true
    @window.one 'scrollstop', => @scrolling = false

  onMouseWheelStart: (e) =>
    return if @isMouseWheeling
    @window.trigger 'mousewheelstart'
    @isMouseWheeling = true
    @window.one 'mousewheelstop', => @isMouseWheeling = false

  appReady: =>
    @log 'appReady'
    options =
      history: true
      shim: false

    @render()

    Spine.Route.setup options


  setLanguage: (Route, path) =>
    Nex.language = path?.match(/^\/([\w]{2})/i)?[1] or 'en'

  setBodyClass: (Route, path) =>
    path = '/home' if path is '/'
    document.body.className = (path.replace(/\//g, ' ')).trim?()

  onNavigate: (e) =>
    href = $(e.target).closest('a').attr('href')
    @navigate href if href and not href.match(/^http/)

  render: ->
    # selctions
    @append @home            = new Home
    @append @contact         = new Nex.Contact

    @manager.add    \
      @home,        \
      @contact

    # @delay =>
    #   @navigate '/de/products/system/venear'
    # , 500

  goHome: =>
    @navigate '/'



module.exports = App




