class AddIndexToPostsOrigPosts < ActiveRecord::Migration
  def self.up
    add_index :orig_posts, [:url, :origin_id, :user_id]
    add_index :posts, [:ted_id, :user_id, :orig_post_id]
  end

  def self.down
    remove_index :orig_posts, [:url, :origin_id, :user_id]
    remove_index :posts, [:ted_id, :user_id, :orig_post_id]
  end
end
