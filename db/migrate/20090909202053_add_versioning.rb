class AddVersioning < ActiveRecord::Migration
  def self.up
	  Post.create_versioned_table
  end

  def self.down
	  Post.drop_versioned_table
  end
end
