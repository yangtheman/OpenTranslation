# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  require 'shorturl'

  include ExceptionNotifiable

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_facebook_session, :fetch_logged_in_user
  helper_method :logged_in?, :facebook_session

  local_addresses.clear

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def login_required
    return true if logged_in?
    session[:return_to] = request.request_uri
    redirect_to new_session_path and return false
  end

  def cleanup(txt)
	  txt.gsub!(/\&\#8211\;/, '–')
	  txt.gsub!(/\&\#8212\;/, '—')
	  txt.gsub!(/\&\#8216\;/, '‘')
	  txt.gsub!(/\&\#8217\;/, '’')
	  txt.gsub!(/\&\#8218\;/, '‚')
	  txt.gsub!(/\&\#8220\;/, '“')
	  txt.gsub!(/\&\#8221\;/, '”')
	  txt.gsub!(/\&\#8222\;/, '„')
	  txt.gsub!(/\&\#8224\;/, '†')
	  txt.gsub!(/\&\#8225\;/, '‡')
	  txt.gsub!(/\&\#8226\;/, '•')
	  txt.gsub!(/\&\#8230\;/, '…')
	  txt.gsub!(/\&\#8240\;/, '‰')
	  txt.gsub!(/\&\#8364\;/, '€')
	  txt.gsub!(/\&\#8482\;/, '™')
	  txt
  end

  def translate(body, from, to)
	  ted_content = ""
	  body.each do |p|
		  ted_content += Translate.t(cleanup(p.to_html), from, to)
	  end
	  ted_content
  end

  def tweetthis(post)
    twitter_title = OrigPost.find(post.orig_post_id).title.gsub(/[ \t]+/, '+') # change to twitter-friendly title                   
    url = "http://opent.heroku.com/posts/#{post.id}?version=#{post.version}"
    url = ( ShortURL.shorten(url) rescue nil ) || url
    "http://www.twitter.com/home/?status=Just+translated+to+#{post.target_lang.language}!+-+#{twitter_title}+#{url}"
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

  def facebook_user?
    return @current_user && !@current_user.fb_user_id.nil? && @current_user.fb_user_id > 0
  end

end
