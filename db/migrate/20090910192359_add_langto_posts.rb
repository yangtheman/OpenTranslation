class AddLangtoPosts < ActiveRecord::Migration
  def self.up
	  add_column :posts, :origin_id, :integer
	  add_column :posts, :ted_id, :integer
	  add_column :post_versions, :origin_id, :integer
	  add_column :post_versions, :ted_id, :integer
  end

  def self.down
	  remove_column :posts, :origin_id
	  remove_column :posts, :ted_id
	  remove_column :post_versions, :origin_id
	  remove_column :post_versions, :ted_id
  end
end
