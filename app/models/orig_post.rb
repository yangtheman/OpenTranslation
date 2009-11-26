class OrigPost < ActiveRecord::Base

  require 'open-uri'

  has_many :posts
  belongs_to :users
  belongs_to :orig_lang, :class_name => 'Language', :foreign_key => 'origin_id'

  validates_uniqueness_of :url, :case_sensitive => false

  def self.top(num=5)
    orig_cols = OrigPost.column_names.collect {|c| "orig_posts.#{c}"}.join(",")
    return OrigPost.find_by_sql("SELECT #{orig_cols}, count(posts.id) AS post_count FROM orig_posts LEFT OUTER JOIN posts ON posts.orig_post_id = orig_posts.id GROUP BY orig_posts.id, #{orig_cols} ORDER BY post_count DESC LIMIT #{num}")
  end

  def self.newentry(user, params)
    orig = user.orig_posts.new
    orig.url = params[:url]
    orig.author = params[:url].scan(/http:\/\/[\w.]+/)[0]
    orig.origin_id = params[:post][:origin_id]

    from = Language.find_by_id(params[:post][:origin_id]).short

    web = Hpricot(open(orig.url))

    orig.title = web.at("title").inner_text

    #remove all images (shall I or not?)
    #web.search("img").remove

    # Paul Graham's essays built tables
    if orig.url =~ /paulgraham\.com/
      body = ""
      bodyarr = web.at('body').inner_html.split('<br /><br />')
      # Skip elements with table open and close tags
      # Wrap each paragraph with <p></p> tags
      bodyarr.each do |para|
	if !(para =~ /<[\/]*table/)
	  body << "<p>#{para}</p>"
	end
      end
      orig.content = body
    else 
      #Wordpress's main body has "entry" div id
      body = web.search("div.entry/p")
      if body.inner_text.length == 0
	body = web.search("/html/body//p")
      end
      orig.content = body.to_html
    end

    orig.save

    return orig
  end

end
