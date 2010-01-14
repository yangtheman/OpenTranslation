class RemoveRatingsFromUserandPost < ActiveRecord::Migration
  def self.up
    remove_column :post_versions, :url
    remove_column :posts, :rating_count
    remove_column :posts, :rating_total
    remove_column :posts, :rating_avg
    remove_column :users, :rating_count
    remove_column :users, :rating_total
    remove_column :users, :rating_avg
  end

  def self.down
  end
end
