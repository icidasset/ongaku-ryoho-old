module ApplicationHelper

  def body_class(title)
    title.parameterize
  end

  def application_css_filename
    default = "blue-silver"

    if current_user
      theme = current_user.settings["theme"] || default
    else
      theme = default
    end

    "application_#{theme}"
  end

  def theme_names
    %w(
      aqua
      blue-silver
      earth
      evening
      forest
      grass
      pink-lad
      purple-rain
      red-stone
      swamp
    )
  end

end
