class OrigPost < ActiveRecord::Base

  require 'hpricot'
  require 'open-uri'

  has_many :posts
  belongs_to :users
  belongs_to :orig_lang, :class_name => 'Language', :foreign_key => 'origin_id'

  validates_uniqueness_of :url, :case_sensitive => false

  def self.top(num)
    orig_cols = OrigPost.column_names.collect {|c| "orig_posts.#{c}"}.join(",")
    return OrigPost.find_by_sql("SELECT #{orig_cols}, count(posts.id) AS post_count FROM orig_posts LEFT OUTER JOIN posts ON posts.orig_post_id = orig_posts.id GROUP BY orig_posts.id, #{orig_cols} ORDER BY post_count DESC LIMIT #{num}")
  end

  def self.newentry(user, params)
    orig = user.orig_posts.new
    orig.url = params[:url]
    orig.origin_id = params[:post][:origin_id]

    from = Language.find_by_id(params[:post][:origin_id]).short

    web = Hpricot(open(orig.url))

    orig.title = web.at("title").inner_text

    #remove all images (shall I or not?)
    #web.search("img").remove

    #Wordpress's main body has "entry" div id
    body = web.search("div.entry/p")
    if body.inner_text.length == 0
      body = web.search("/html/body//p")
    end
    #body = web.search("/html/body/")

    orig.content = body.to_html
    #ted_content = ""
    #body.each do |p|
      #ted_content += Translate.t(cleanup(p.to_html), from, to)
    #end

    orig.save

    return orig
  end


end
