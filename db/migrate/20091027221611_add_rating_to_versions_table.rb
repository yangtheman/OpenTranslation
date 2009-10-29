class AddRatingToVersionsTable < ActiveRecord::Migration
  def self.up
    add_column :post_versions, :rating_count, :integer
    add_column :post_versions, :rating_total, :decimal, :precision => 10, :scale => 0
    add_column :post_versions, :rating_avg, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :post_versions, :rating_count
    remove_column :post_versions, :rating_total
    remove_column :post_versions, :rating_avg
  end
end
