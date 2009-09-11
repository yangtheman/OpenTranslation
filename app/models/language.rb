class Language < ActiveRecord::Base
	belongs_to :posts
	belongs_to :post_versions
end
