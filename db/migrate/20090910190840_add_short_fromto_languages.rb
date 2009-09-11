class AddShortFromtoLanguages < ActiveRecord::Migration
  def self.up
	  add_column :languages, :short, :string
  end

  def self.down
	  remove_column :languages, :short
  end
end
