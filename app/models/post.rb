class Post < ActiveRecord::Base
	has_many :languages
  	#validates_format_of :url, :with => %r{\Ahttp://[A-Za-z0-9][\w./]*\.[\w./]*\Z}

	acts_as_versioned

	validates_uniqueness_of :url, :scope => :ted_id, :case_sensitive => false

end
                                             
