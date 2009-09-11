class Post < ActiveRecord::Base
	has_many :languages

	acts_as_versioned
end
