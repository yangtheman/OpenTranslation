class AddVersiontoRatings < ActiveRecord::Migration
  def self.up
    add_column :ratings, :rated_ver, :integer
  end

  def self.down
    remove_column :ratings, :rated_ver
  end
end
