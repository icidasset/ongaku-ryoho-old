class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_pages

  def not_authenticated
    redirect_to sign_in_url, :alert => "First login to access this page."
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def redirect_if_logged_in
    if user_signed_in?
      redirect_to root_url
      return false
    else
      return true
    end
  end

private

  def set_pages
    @pages = pages
    @page = @pages.find { |p| p[:url] == request.path }
  end

  def pages
    if user_signed_in?
      [
        { title: "Application", url: "/" },
        { title: "Settings", url: "/settings" },
        { title: "Account", url: "/account"},
        { title: "Sign out", url: "/sign-out" }
      ]
    else
      [
        { title: "About", url: "/about" },
        { title: "Sign in", url: "/sign-in" },
        { title: "Sign up", url: "/sign-up" },
        { title: "Recover password", url: "/password", visible: false },
        { title: "Recover password", url: "/password/new", visible: false },
        { title: "Recover password", url: "/password/edit", visible: false }
      ]
    end
  end

end
