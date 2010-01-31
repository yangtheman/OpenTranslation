class Orig < ActiveRecord::Base

  require 'open-uri'

  has_many :posts
  belongs_to :user
  belongs_to :language, :foreign_key => "origin_id"

  validates_presence_of :url, :user_id, :origin_id
  validates_uniqueness_of :url, :case_sensitive => false
  validates_format_of :url, :with => /^((http|https?):\/\/((?:[-a-z0-9]+\.)+[a-z]{2,}))/, :on => :create, :message => "has an invalid format"

  def self.top(num=5)
    orig_cols = Orig.column_names.collect {|c| "origs.#{c}"}.join(",")
    return Orig.find_by_sql("SELECT #{orig_cols}, count(posts.id) AS post_count FROM origs LEFT OUTER JOIN posts ON posts.orig_id = origs.id GROUP BY origs.id, #{orig_cols} ORDER BY post_count DESC LIMIT #{num}")
  end

  def self.extract_body(web, url)
    #remove all images (shall I or not?)
    #web.search("img").remove

    # Remove comments and footer section
    web.search("#comments").remove
    web.search("div.comments").remove
    web.search("div.entry-footer").remove
    
    # Paul Graham's essays are built with tables
    if url =~ /paulgraham\.com/
      # Skip elements with table open and close tags
      # Wrap each paragraph with <p></p> tags
      bodyarr = web.at('body').inner_html.split('<br /><br />').select {|para| para !~ /<[\/]*table/}
      body = bodyarr.map {|para| "<p>#{para}</p>"}.join
    elsif url =~ /googleblog\.blogspot\.com/ 
      body = web.search("div.post-body").to_html.split('<br /><br />').map {|para| "<p>#{para}</p>"}.join
    else
      # Wordpress's main body has "post-content", "entry" or "entry-content" div class
      # Typepad's main body has "entry-body" div class
      if (body = web.search("div.post-content")).size > 0
      elsif (body = web.search("div.entry-body")).size > 0 
      elsif (body = web.search("div.entry-content")).size > 0 
      elsif (body = web.search("div.entry")).size > 0
      else
	body = web.search("/html/body")
      end
      body.to_html
    end
  end

  def newentry
    self.author = self.url.scan(/http:\/\/[\w.]+/)[0]
    
    begin
      web = Hpricot(open(self.url))
    rescue
      return nil
    end

    self.title = web.at("title").inner_text
    self.content = Orig.extract_body(web, self.url)
    
    save
  end

end
