# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  require 'hpricot'
  require 'open-uri'
  require 'rtranslate'

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

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
end
