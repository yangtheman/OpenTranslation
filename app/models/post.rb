class Post < ActiveRecord::Base
  #after_save :send_facebook_feed

  require 'rtranslate'

  belongs_to :orig
  belongs_to :user
  belongs_to :language, :foreign_key => "ted_id"

  acts_as_rated :with_stats_table => true
  #acts_as_ferret :fields => [:title, :content]

  acts_as_versioned :if_changed => [:title, :content] do
    def self.included(base)
      base.belongs_to :user
      base.belongs_to :language, :foreign_key => "ted_id"
      base.belongs_to :orig
    end
  end

  validates_presence_of :orig_id, :user_id

  # Fields for texticle to search
  index do
    title   'A'
    content 'B'
  end
  
  def self.top(limit = 5)
    self.find(:all, :order => "created_at DESC", :limit => limit)
  end

  def prep(target_lang_id, orig)
    self.ted_id = target_lang_id

    from = orig.language.short
    to = self.language.short

    # Translate title first
    self.title = Translate.t(orig.title, from, to)
    if self.title =~ /^Error\: Translation from.*supported yet\!/
      return false
    else 
      self.content = para_translate(orig.content, from, to)
    end
  end 

  def cleanup(txt)
    txt.gsub!(/\&\#8211\;/, '–')
    txt.gsub!(/\&\#8212\;/, '—')
    txt.gsub!(/\&\#8216\;/, '‘')
    txt.gsub!(/\&\#8217\;/, '’')
    txt.gsub!(/\&\#8218\;/, '‚')
    txt.gsub!(/\&\#8220\;/, '“')
    txt.gsub!(/\&\#8221\;/, '”')
    txt.gsub!(/\&\#8222\;/, '„')
    txt.gsub!(/\&\#8224\;/, '†')
    txt.gsub!(/\&\#8225\;/, '‡')
    txt.gsub!(/\&\#8226\;/, '•')
    txt.gsub!(/\&\#8230\;/, '…')
    txt.gsub!(/\&\#8240\;/, '‰')
    txt.gsub!(/\&\#8364\;/, '€')
    txt.gsub!(/\&\#8482\;/, '™')
    txt
  end

  def para_translate(body, from, to)
    paras = Hpricot(body).search("/p")
    ted_content = ""
    paras.each do |p|
      ted_content += Translate.t(cleanup(p.to_html), from, to)
    end
    ted_content
  end

end

