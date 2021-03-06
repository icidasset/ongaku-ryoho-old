class OngakuRyoho.Classes.Models.Filter extends Backbone.Model

  defaults:
    playlist: off
    playlist_name: false
    playlist_isspecial: false
    searches: []
    favourites: off
    page: 1
    per_page: 500
    total: 0
    sort_by: "artist"
    sort_direction: "asc"



  initialize: () ->
    tpp = OngakuRyohoPreloadedData.user.settings.tracks_per_page

    if tpp
      tpp = parseInt(tpp, 10) if typeof tpp is "string"
      this.set("per_page", tpp, { silent: true })

    this.on("change", this.change_handler)
    this.on("change:playlist", this.playlist_change_handler)
    this.on("change:sort_by", this.sort_by_change_handler)
    this.on("change:sort_direction", this.sort_by_change_handler)



  change_handler: () ->
    if OngakuRyoho.People.ViewStateManager.state.ready
      OngakuRyoho.RecordBox.Tracks.collection.fetch()
      OngakuRyoho.People.ViewStateManager.save_state_in_local_storage()



  #
  #  Playlist
  #
  enable_playlist: (model) ->
    value = if model.get("special")
      "#{model.get('name')}/"
    else
      model.get("id")

    sort_by = unless model.get("special")
      "position"
    else
      if this.get("sort_by") is "position"
        "artist"
      else
        this.get("sort_by")

    sort_direction = unless model.get("special")
      "asc"
    else
      this.get("sort_direction")

    this.search_action_reset()
    this.set({
      playlist: value,
      playlist_name: model.get("name"),
      playlist_isspecial: model.get("special"),
      sort_by: sort_by,
      sort_direction: sort_direction
    })



  disable_playlist: () ->
    sort_by = if this.get("sort_by") is "position"
      OngakuRyoho.RecordBox.TLS.model.get_current_default_sortby_column()
    else
      this.get("sort_by")

    this.search_action_reset()
    this.set({
      playlist: off,
      playlist_name: false,
      playlist_isspecial: false,
      sort_by: sort_by
    })



  playlist_change_handler: () ->
    OngakuRyoho.RecordBox.PlaylistMenu.machine.add_active_class_to_selected_playlist()



  #
  #  Favourites
  #
  toggle_favourites: () ->
    this.search_action_reset()
    this.set("favourites", !this.get("favourites"))



  disable_favourites: () ->
    this.search_action_reset()
    this.set("favourites", off)



  #
  #  Search
  #
  add_search_query: (query) ->
    searches = if query.charAt(0).match(/^(\+|\-)$/g)
      this.get("searches").slice(0)
    else
      []

    # check
    if query.length is 0 or query is "+" or query is "-"
      return no

    # update query depending on action
    if query.charAt(0) is "-"
      query = "!#{query.substr(1)}"
      query = this.clean_up_search_query(query, 1)
    else
      query = query.substr(1) if query.charAt(0) is "+"
      query = this.clean_up_search_query(query)

    # check again
    if query.length is 0
      return message = new OngakuRyoho.Classes.Models.Message({
        text: "Invalid search query",
        error: true
      })

    # set searches
    searches.push(query)
    this.search_action_reset()
    this.set("searches", searches)



  remove_search_query: (query) ->
    searches = this.get("searches").slice(0)
    indexof_query = _.indexOf(searches, query)

    if indexof_query isnt -1
      searches.splice(indexof_query, 1)
      this.search_action_reset()
      this.set("searches", searches)



  clean_up_search_query: (query, from_index) ->
    new_query = query
    new_query = new_query.substr(from_index) if from_index
    new_query = new_query.replace(/(\:|\*|\&|\||\'|\"|\+|\!)+/g, "")
    new_query = query.substr(0, from_index) + new_query if from_index
    new_query



  #
  #  Reset
  #
  search_action_reset: () ->
    this.set("page", 1, { silent: true })



  #
  #  Other
  #
  sort_by_change_handler: (e) ->
    OngakuRyoho.RecordBox.Navigation.machine.add_active_class_to_selected_sort_by_column()



  remove_last_filter_in_line: () ->
    attr = this.attributes

    if attr.searches.length > 0
      this.remove_search_query(_.last(attr.searches))
    else if attr.favourites
      this.disable_favourites()
    else if attr.playlist
      this.disable_playlist()



  is_in_playlist_mode: () ->
    a = (typeof this.get("playlist") is "number")
    b = (this.get("searches").length is 0)
    c = (this.get("favourites") is off)
    d = (this.get("sort_by") is "position")

    if a and b and c and d
      return true
    else
      return false
