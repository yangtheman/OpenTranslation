# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  require 'shorturl'

  # Need to get sending email work on Heroku
  #include ExceptionNotifiable
  #local_addresses.clear

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_facebook_session, :fetch_logged_in_user, :clickpass_params
  helper_method :logged_in?, :facebook_session

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  def clickpass_params
    if ENV['RAILS_ENV'] == 'production'
      @clickpass_site_key = 'rzMQEOe8gQ'
      @clickpass_callback_url = 'alpha.bloglation.com'
    else
      @clickpass_site_key = 'CNxswsAO8P'
      @clickpass_callback_url = '127.0.0.1%3A3000'
    end
  end 

  def login_required
    return true if logged_in?
    session[:return_to] = request.request_uri
    redirect_to new_session_path and return false
  end

  protected
    def fetch_logged_in_user
      if facebook_session
	@current_user = User.find_by_fb_user(facebook_session.user)
      else
	return unless session[:user_id]
	@current_user = User.find_by_id(session[:user_id])
      end
    end

    def logged_in?
      !@current_user.nil?
    end

    def ua_identifier(ua_string)
      return "Chrome" if ua_string =~ /Chrome/i
      return "Internet Explorer" if ua_string =~ /MSIE/
      return "Safari" if ua_string =~ /Safari/
      return "Firefox" if ua_string =~ /Firefox/i
      return "Opera" if ua_string =~ /Opera/i
      return "Other"
    end

end
