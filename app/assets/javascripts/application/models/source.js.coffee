class OngakuRyoho.Classes.Models.Source extends Backbone.Model

  defaults:
    available: false
    processing: false



  initialize: () ->
    this.set_type_instance()
    this.set_available()
    this.on("change", this.set_available)



  set_type_instance: () ->
    if this.attributes.type
      this.type_instance = new OngakuRyoho.Classes.SourceTypes[this.attributes.type]()
      this.type_instance[this.attributes.type.toLowerCase()] = this



  is_available: () ->
    this.type_instance.is_available()



  set_available: () =>
    available = this.is_available()
    this.set("available", available)



  poll_for_busy_state: () ->
    promise = new RSVP.Promise()
    tries = 0
    max_tries = (60 * 12) * 2 # 5 minutes * 12 = 60 minutes * 2 = 2 hours

    # success
    success = () =>
      if this.get("busy") and tries < max_tries
        exec()
      else
        promise.resolve()

      tries++

    # fetch
    fetch = () =>
      this.fetch({ success: success })

    # exec
    exec = () ->
      _.delay(fetch, 5000)

    # go
    exec()

    # promise
    return promise



  get_file_list: () ->
    promise = new RSVP.Promise()
    url = "#{this.url()}/file_list"

    # get
    if this.get("processed")
      $.getJSON(url, (r) -> promise.resolve(r))
    else
      promise.resolve([])

    # return
    promise



  #
  #  Update tracks
  #
  update_tracks: () ->
    promise = new RSVP.Promise()

    # check
    this.set_type_instance() unless this.type_instance

    # state
    this.set("processing", true)

    # after
    after = (has_changed) =>
      this.set("processing", false)
      promise.resolve(has_changed)

    # update
    this.get_file_list()
      .then(this.type_instance.update_tracks)
      .then(this.process_data_from_source)
      .then(after)

    # return
    promise



  process_data_from_source: (data) =>
    promise = new RSVP.Promise()
    url = "#{this.url()}/update_tracks"
    original_updated_at = this.get("updated_at")

    # state
    has_changed = false

    # request data
    request_data = { data: data }
    request_data[window._auth_token_name] = window._auth_token

    # process
    if data
      $.ajax(
        type: "POST"
        url: url
        data: request_data
        success: (response) =>
          if response.working
            this.poll_for_busy_state().then () =>
              has_changed = true if this.get("updated_at") isnt original_updated_at
              promise.resolve(has_changed)
          else
            promise.resolve(has_changed)

        error: () ->
          promise.resolve(has_changed)
      )

    else
      promise.resolve(has_changed)

    # return
    promise
