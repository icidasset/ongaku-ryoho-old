class OngakuRyoho.Views.TrackList extends Backbone.View
  
  #
  #  Events
  #
  events:
    "dblclick .track" : "play_track"
    "click .track .favourite" : "track_rating_star_click"



  #
  #  Initialize
  #
  initialize: () =>
    @collection = Tracks
    @collection.on("reset", this.render)
    @collection.on("fetching", this.fetching)
    @collection.on("fetched", this.fetched)

    # track list (window) resize
    $(window).on("resize", this.resize)
             .trigger("resize")



  #
  #  Render
  #
  render: () =>
    html = "<ol class=\"tracks\">"

    # sources html
    @collection.each((track) =>
      track_view = new OngakuRyoho.Views.Track({ model: track })
      html += track_view.render().el.innerHTML
    )

    # ending html
    html += "</ol>"

    # set html
    this.$el.html(html)

    # trigger resize
    $(window).trigger("resize")

    # set footer contents
    if this.count_tracks() is 0
      message = ""

    else
      page_info = @collection.page_info()
      
      word = {
        pages: (if page_info.pages is 1 then "page" else "pages")
        tracks: (if page_info.total is 1 then "track" else "tracks")
      }

      message =  "#{page_info.total} #{word.tracks} found &mdash;
                  page #{page_info.page} / #{page_info.pages}"
    
    PlaylistView.set_footer_contents(message)

    # chain
    return this



  #
  #  Fetching and fetched events
  #
  fetching: () =>



  fetched: () =>
    PlaylistView.check_page_navigation()
    
    if this.count_tracks() is 0
      this.$el.html("<div class=\"nothing-here\" />")

    else
      this.add_playing_class_to_track( SoundGuy.get_current_track() )
      PlaylistView.show_current_track()



  #
  #  Resize
  #
  resize: (e) =>
    $list = this.$el.closest(".list")

    new_height = (
      $(window).height() - 2 * 50 -
      $list.prev(".navigation").height() - 2 * 2 -
      $list.children("header").height() -
      $list.next("footer").height()
    )

    $tw = this.$el

    $tw.height(new_height) if $tw



  #
  #  Add playing class to track
  #
  add_playing_class_to_track: (track) =>
    return unless track
    
    # set elements
    $track = this.$el.find(".track[rel=\"#{track.cid}\"]")
    
    # set classes
    $track.parent().children(".track.playing").removeClass("playing")
    $track.addClass("playing")



  #
  #  Play track
  #
  play_track: (e) =>
    $t = $(e.currentTarget)
    
    # check
    return if not soundManager.ok() or $t.hasClass("unavailable")

    # set
    track = Tracks.getByCid($t.attr("rel"))

    # insert track
    SoundGuy.insert_track(track)
    
    # set elements
    $playpause_button_light = ControllerView.$el.find(".controls a .button.play-pause .light")
    
    # turn the play button light on
    $playpause_button_light.addClass("on")



  #
  #  Count tracks
  #
  count_tracks: () =>
    return this.$el.find(".track").length



  #
  #  Track rating star click event
  #
  track_rating_star_click: (e) =>
    $t = $(e.currentTarget)
    $track = $t.closest(".track")
    
    title = $track.find(".title span").text()
    artist = $track.find(".artist span").text()
    
    # check
    if $t.data("favourite")
      $t.attr("data-favourite", false)
      $t.data("favourite", false)
      
      this.remove_matching_favourites(title, artist)
      
    else
      $t.attr("data-favourite", true)
      $t.data("favourite", true)
      
      this.create_new_favourite(title, artist)
    
    # prevent default
    e.preventDefault()
    e.stopPropagation()
    return false



  create_new_favourite: (title, artist) =>
    Favourites.create({
      track_title: title,
      track_artist: artist
    })



  remove_matching_favourites: (title, artist) =>
    favourites = Favourites.where({
      track_title: title,
      track_artist: artist
    })
    
    # destroy each
    _.each favourites, (f) -> f.destroy()
