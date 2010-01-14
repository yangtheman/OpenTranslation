class AddVerionToRatingStatistics < ActiveRecord::Migration
  def self.up
    add_column :rating_statistics, :rated_ver, :integer
    remove_column :post_versions, :rating_count
    remove_column :post_versions, :rating_total
    remove_column :post_versions, :rating_avg
    remove_column :posts, :url
  end

  def self.down
    remove_column :rating_statistics, :rated_ver
  end
end
