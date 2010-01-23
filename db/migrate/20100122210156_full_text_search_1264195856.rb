class FullTextSearch1264195856 < ActiveRecord::Migration
  def self.up
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS posts_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index posts_fts_idx
        ON posts
        USING gin((to_tsvector('english', coalesce(posts.title, '') || ' ' || coalesce(posts.content, ''))))

      eosql
  end
end
