class Language < ActiveRecord::Base
  has_many :posts
  has_many :origs

  def all 
    self.find(:all, :order => "language ASC")
  end
end
