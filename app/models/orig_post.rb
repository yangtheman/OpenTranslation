class OrigPost < ActiveRecord::Base
  has_many :posts
  belongs_to :users
  belongs_to :orig_lang, :class_name => 'Language', :foreign_key => 'origin_id'

  validates_uniqueness_of :url, :case_sensitive => false

  def self.top(num)
    orig_cols = OrigPost.column_names.collect {|c| "orig_posts.#{c}"}.join(",")
    return OrigPost.find_by_sql("SELECT #{orig_cols}, count(posts.id) AS post_count FROM orig_posts LEFT OUTER JOIN posts ON posts.orig_post_id = orig_posts.id GROUP BY orig_posts.id, #{orig_cols} ORDER BY post_count DESC LIMIT #{num}")
  end
end
