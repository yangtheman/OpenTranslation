class AddRatingToPost < ActiveRecord::Migration
  def self.up
    Post.add_ratings_columns 
  end

  def self.down
    Post.remove_ratings_columns 
  end
end
