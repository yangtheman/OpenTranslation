class ChangePostVersions < ActiveRecord::Migration
  def self.up
    rename_column :post_versions, :orig_post_id, :orig_id
  end

  def self.down
    rename_column :post_versions, :orig_id, :orig_post_id
  end
end
