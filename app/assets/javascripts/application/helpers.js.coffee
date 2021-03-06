window.Helpers =

  #
  #  Initialize (before)
  #
  initialize_before: () ->
    this.original_document_title = document.title

    # touch
    unless Modernizr.touch
      $("html").addClass("no-touch")

    # handlebars
    this.setup_handlebars_helpers()

    # request animation frame
    window.requestAnimationFrame = (
      window.requestAnimationFrame ||
      window.webkitRequestAnimationFrame ||
      window.mozRequestAnimationFrame
    )

    window.cancelAnimationFrame = (
      window.cancelAnimationFrame ||
      window.webkitCancelRequestAnimationFrame ||
      window.mozCancelRequestAnimationFrame
    )

    # pointerevents drag & drop
    this.pedd = new PointerEventsDragnDrop(
      document.body, {
        delegate_selector: "[draggable]"
      }
    )

    # ajax before send
    $.ajaxSettings.beforeSend = (xhr, settings) ->
      return if (settings.crossDomain)
      return if (settings.type == "GET")

      token = $('meta[name="csrf-token"]').attr('content')
      if (token) then xhr.setRequestHeader('X-CSRF-Token', token)



  #
  #  Template, view helpers
  #
  get_template: (template_name) ->
    html = $("[data-template-name=\"#{template_name}\"]").html()
    return Handlebars.compile(html)



  set_view_element: (view, element) ->
    element = if typeof element is String
      document.querySelector(element)
    else
      element

    view.setElement(element)



  setup_handlebars_helpers: () ->
    # icons
    Handlebars.registerHelper("if_has_icon", (block) ->
      return block(this) if @icon and @icon_type
    )


  set_document_title: (text, set_original_title) ->
    this.original_document_title = document.title if set_original_title
    document.title = text



  #
  #  CSS Helpers
  #
  css:
    rotate: ($el, degrees) ->
      css = {}

      css["-webkit-transform"] = "rotate(" + degrees + "deg)"
      css["-moz-transform"] = css["-webkit-transform"]
      css["-o-transform"] = css["-webkit-transform"]
      css["-ms-tranform"] = css["-webkit-transform"]
      css["transform"] = css["-webkit-transform"]

      $el.css(css)



  #
  #  Loading animation
  #
  add_loading_animation: (target, color="#fff", radius=4) ->
    options =
      lines: 10
      length: 1
      width: 1
      radius: radius
      rotate: 90
      color: color
      speed: 1
      trail: 60
      shadow: false

    spinner = new Spinner(options).spin(target)



  #
  #  Async stuff
  #
  promise_fetch: (obj) ->
    promise = new RSVP.Promise()

    obj.fetch.call(obj, {
      success: (model, response) -> promise.resolve(response)
      error: -> promise.reject()
    })

    return promise



  #
  #  Other
  #
  responsive_state: () ->
    w = document.body.offsetWidth
    s = null

    if w >= 1240
      s = "large"
    else if w < 1240 and w >= 800
      s = "medium"
    else if w < 800 and w >= 480
      s = "small"
    else
      s = "extra-small"

    # return
    s
