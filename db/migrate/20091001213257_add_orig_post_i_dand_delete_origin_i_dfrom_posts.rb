class AddOrigPostIDandDeleteOriginIDfromPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :orig_post_id, :integer
    add_column :post_versions, :orig_post_id, :integer
  end

  def self.down
    remove_column :posts, :orig_post_id
    remove_column :post_versions, :orig_post_id
  end
end
