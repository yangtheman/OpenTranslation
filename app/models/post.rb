class Post < ActiveRecord::Base
  #after_save :send_facebook_feed

  require 'rtranslate'

  named_scope :top, :order => "created_at DESC", :limit => 5

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

  def prep(target_lang_id, orig)
    self.ted_id = target_lang_id

    from = orig.language.short
    to = self.language.short

    # Translate title first
    self.title = Translate.t(cleanup(orig.title), from, to)
    if self.title =~ /^Error\: Translation from.*supported yet\!/
      return false
    else
      #self.content = para_translate(orig.content, from, to)
      #paras = Hpricot(orig.content).search("/p|/pre|/h[1-6]")
      #self.content = paras.map {|p| Translate.t(cleanup(p.to_html), from, to)}.join
      self.content = ""
      paras = Hpricot(orig.content).search('*')
      counter = 0
      while paras.size > 0 && !paras[counter].nil?
	elem = paras[counter]
	if elem.name =~ /^(p|h[1-6]|span)$/ || (elem.class.to_s =~ /Text/ && elem.name =~ /^\w+/ && elem.name.size > 10)
	  self.content << Translate.t(cleanup(elem.to_html), from, to)
	  paras = elem.following
	  counter = 0
	elsif elem.name =~ /^(pre|code)$/
	  self.content << elem.to_html
	  paras = elem.following
	  counter = 0
	else
	  counter += 1
	end
      end
      self
    end
  end


  def cleanup(txt)
    txt.gsub!(/\&ndash\;|\&\#8211\;/, '–')
    txt.gsub!(/\&mdash\;|\&\#8212\;/, '—')
    txt.gsub!(/\&lsquo\;|\&\#8216\;/, '‘')
    txt.gsub!(/\&rsquo\;|\&\#8217\;/, '’')
    txt.gsub!(/\&sbquo\;|\&\#8218\;/, '‚')
    txt.gsub!(/\&ldquo\;|\&\#8220\;/, '“')
    txt.gsub!(/\&rdquo\;|\&\#8221\;/, '”')
    txt.gsub!(/\&bdquo\;|\&\#8222\;/, '„')
    txt.gsub!(/\&\#8224\;/, '†')
    txt.gsub!(/\&\#8225\;/, '‡')
    txt.gsub!(/\&\#8226\;/, '•')
    txt.gsub!(/\&\#8230\;/, '…')
    txt.gsub!(/\&\#8240\;/, '‰')
    txt.gsub!(/\&euro\;|\&\#8364\;/, '€')
    txt.gsub!(/\&\#8482\;/, '™')
    txt.gsub!(/\&\#0160\;/, ' ')
    txt.gsub!(/\&\#0?39\;/, '\'')
    txt.gsub!(/\&quot\;/, '\"')
    txt.gsub!(/\&lt\;/, '<')
    txt.gsub!(/\&gt\;/, '>')
    txt.gsub!(/\&amp\;|\&\#0?38\;/, 'and')
    txt.gsub!(/\&/, 'and')
    txt
  end

end

