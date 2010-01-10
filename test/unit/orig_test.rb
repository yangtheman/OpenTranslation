require 'test_helper'

class OrigTest < ActiveSupport::TestCase

  setup do
    Factory.create(:orig)
  end

  should_have_many :posts
  should_belong_to :user
  should_belong_to :language
  should_validate_uniqueness_of :url, :case_sensitive => false
  should_validate_presence_of :url
  should_validate_presence_of :user_id
  should_validate_presence_of :origin_id
  should_allow_values_for :url, "http://www.web.com", "http://web.com", "https://www.web.com"
  should_not_allow_values_for :url, "htp://www.web.com", "ftp://web.com", "http://com", "http://web"

  context "An original blog" do
    setup do 
      @user1 = Factory.create(:user)
      @web_content1 = '<html><head><title>Awesome Blog</title></head><body><div id="entry"><p>Awesome Content</p><p>Awesome Content 2</p></div></body></html>'
      @web_content2 = '<html><head><title>PG Blog</title></head><body>Paragraph 1<br /><br />Paragraph 2</body></html>'
    end

    should "be created by a user if no previous URL exists" do
      orig = Factory.build(:orig)
      assert orig.valid?
      assert orig.save
    end

    should "not be created without user_id" do
      orig = Factory.build(:orig, :user_id => nil)
      assert !orig.valid?
      assert !orig.save
    end

    should "not be created without URL field" do
      orig = Factory.build(:orig, :url => nil)
      assert !orig.valid?
      assert !orig.save
    end

    should "scrape and get content of Wordpress-like website" do
      orig = Factory.create(:orig)
      OpenURI.expects(:open_uri).returns(@web_content1)
      orig.newentry

      assert_equal orig.title, "Awesome Blog"
      assert_equal orig.content, "<p>Awesome Content</p><p>Awesome Content 2</p>"
    end

    should "scrape and get content of PG-like website" do
      orig = Factory.create(:orig, :url => "http://www.paulgraham.com/sometext")
      OpenURI.expects(:open_uri).returns(@web_content2)
      orig.newentry

      assert_equal orig.title, "PG Blog"
      assert_equal orig.content, "<p>Paragraph 1</p><p>Paragraph 2</p>"
    end
    
    context "with existing entry" do
      setup do
	@orig = Factory.create(:orig)
      end

      should "not allow another original blog with the same URL to be created" do
	orig2 = Factory.build(:orig, :url => @orig.url)
	assert !orig2.valid?
	assert !orig2.save
      end
    end
  end

  context "Many original blogs" do
    setup do
      10.times do
	@orig = Factory.create(:orig)
	2.times do
	  Factory.create(:post, :orig_id => @orig.id)
	end
      end
    end

    should "return top posts" do
      @origs = Orig.top
      assert_equal @origs.size, 5
    end
  end

end
