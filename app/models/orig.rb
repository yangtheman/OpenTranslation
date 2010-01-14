class Orig < ActiveRecord::Base

  require 'open-uri'
  #acts_as_ferret :fields => [:title, :content, :url]

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

  def self.extract_title(web) 
    web.at("title").inner_text
  end

  def self.extract_body(web, url)
    #remove all images (shall I or not?)
    #web.search("img").remove
    
    # Paul Graham's essays are built with tables
    if url =~ /paulgraham\.com/
      body = ""
      bodyarr = web.at('body').inner_html.split('<br /><br />')
      # Skip elements with table open and close tags
      # Wrap each paragraph with <p></p> tags
      bodyarr.each do |para|
	if !(para =~ /<[\/]*table/)
	  body << "<p>#{para}</p>"
	end
      end
      return body
    elsif url =~ /googleblog\.blogspot\.com/ 
      body = ""
      bodyarr = web.search("div.post-body").to_html.split('<br /><br />')
      bodyarr.each do |para|
	body << "<p>#{para}</p>"
      end
      return body 
    else
      #Wordpress's main body has "entry" div id
      body = web.search("div.entry/p")
      if body.inner_text.length == 0
	body = web.search("/html/body//p")
      end
      return body.to_html
    end
  end

  def newentry
    self.author = self.url.scan(/http:\/\/[\w.]+/)[0]
    
    web = Hpricot(open(self.url))

    self.title = Orig.extract_title(web)
    self.content = Orig.extract_body(web, self.url)
    
    save
  end

end
