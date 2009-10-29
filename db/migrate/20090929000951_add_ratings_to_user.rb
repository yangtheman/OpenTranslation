class AddRatingsToUser < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.create_ratings_table :with_stats_table => true
    User.add_ratings_columns
  end

  def self.down
    User.remove_ratings_columns
    ActiveRecord::Base.drop_ratings_table :with_stats_table => true
  end
end
