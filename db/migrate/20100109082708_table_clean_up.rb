class TableCleanUp < ActiveRecord::Migration
  def self.up
    rename_table :orig_posts, :origs
    rename_column :languages, :language, :name
    rename_column :posts, :orig_post_id, :orig_id
    remove_column :posts, :origin_id
    add_index :origs, [:url, :origin_id, :user_id]
  end

  def self.down
    rename_table :origs, :orig_posts
    rename_column :languages, :name, :language
    rename_column :posts, :orig_id, :orig_post_id
  end
end
