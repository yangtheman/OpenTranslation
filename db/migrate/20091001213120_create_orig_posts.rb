class CreateOrigPosts < ActiveRecord::Migration
  def self.up
    create_table :orig_posts do |t|
      t.string :url
      t.string :title
      t.text :content
      t.string :author
      t.integer :origin_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :orig_posts
  end
end
