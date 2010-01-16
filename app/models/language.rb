class Language < ActiveRecord::Base

  has_many :posts
  has_many :origs

  named_scope :all_ordered, :order => "name ASC"

end
