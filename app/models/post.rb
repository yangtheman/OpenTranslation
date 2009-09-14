class Post < ActiveRecord::Base
	belongs_to :orig_lang,   :class_name => 'Language', :foreign_key => 'origin_id'
	belongs_to :target_lang, :class_name => 'Language', :foreign_key => 'ted_id'
  	#validates_format_of :url, :with => %r{\Ahttp://[A-Za-z0-9][\w./]*\.[\w./]*\Z}

	acts_as_versioned

	validates_uniqueness_of :url, :scope => :ted_id, :case_sensitive => false

end
                                             
