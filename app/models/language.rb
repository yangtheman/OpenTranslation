class Language < ActiveRecord::Base
  has_many :posts_with_this_orig_lang,   :class_name => 'Post', :foreign_key => 'origin_id'
  has_many :posts_with_this_target_lang, :class_name => 'Post', :foreign_key => 'ted_id'
  has_many :orig_posts_with_this_orig_lang, :class_name => 'OrigPost', :foreign_key => 'origin_id'

  def self.all 
    self.find(:all, :order => "language ASC")
  end
end
