class OrigPost < ActiveRecord::Base
  has_many :posts
  belongs_to :users
  belongs_to :orig_lang, :class_name => 'Language', :foreign_key => 'origin_id'

  validates_uniqueness_of :url, :scope => :ted_id, :case_sensitive => false
end
