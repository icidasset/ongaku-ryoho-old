class DropboxAccount < Source

  #
  #  Worker
  #
  def self.worker
    DropboxWorker
  end


  #
  #  Override ActiveRecord::Base.new
  #
  def self.new(attributes=nil, options={}, user_id, ip_address)
    flow = DropboxOAuth2FlowNoRedirect.new(ENV["DROPBOX_APP_KEY"], ENV["DROPBOX_APP_SECRET"])
    authorize_code = attributes[:configuration].delete(:authorize_code).strip

    attributes[:name].strip!

    begin
      access_token, dropbox_user_id = flow.finish(authorize_code)
    rescue Exception
      # bad auth code
      return nil
    end

    client = DropboxClient.new(access_token)
    account_info = client.account_info
    attributes[:configuration][:access_token] = access_token
    attributes[:configuration][:dropbox_user_id] = dropbox_user_id
    attributes[:configuration][:dropbox_account_display_name] = account_info["display_name"]
    attributes[:configuration][:dropbox_account_email] = account_info["email"]

    dropbox = super(attributes, options)
    dropbox.user_id = user_id
    dropbox
  end


  #
  #  Override as_json
  #
  def as_json(options={})
    json = super(options)
    json["configuration"].delete("access_token")

    json
  end


  #
  #  Utility functions
  #
  def self.add_new_tracks(dropbox, new_tracks)
    return unless new_tracks.present?

    # attributes -> models
    new_track_models = new_tracks.map do |tags|
      tags.each do |tag, value|
        tags[tag] = Source.parse_track_tag_value(value)
      end

      new_track_model = Track.new(tags)
      new_track_model.source_id = dropbox.id

      new_track_model
    end

    # save models
    ActiveRecord::Base.transaction do
      new_track_models.each(&:save)
    end
  end


  def self.remove_tracks(dropbox, missing_files)
    return unless missing_files.present?

    # collect tracks
    tracks = Track.where(location: missing_files, source_id: dropbox.id)

    # destroy tracks
    tracks.destroy_all
  end

end
