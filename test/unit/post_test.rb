require 'test_helper'

class PostTest < ActiveSupport::TestCase

  should_belong_to :user
  should_belong_to :orig
  should_belong_to :language

  context "New post" do
    setup do
      @user = Factory.create(:user)
      @en = Factory.create(:language, :name => "english", :short => "en")
      @orig = Factory.create(:orig, :language => @en)
    end

    should "be created when original post exists" do
      post = @orig.posts.new
      post.user_id = @user.id 
      assert post.valid?
      assert post.save
      assert_equal @user.id, post.user_id
      assert_equal @orig.title, post.orig.title
    end

    should "not be created when original post does not exist" do
      post = Factory.build(:post, :orig_id => nil)
      assert !post.valid?
    end

    should "not be created when user_id is nil" do
      post = @orig.posts.new
      assert !post.valid?
    end

    should "be rated by a user" do 
      post = Factory.create(:post)
      post.rate 5, @user

      assert_equal 1, post.rated_count
      assert_equal 5, post.rated_total
    end

    context "ready to be translated" do
      setup do
	Translate.stubs(:t).returns("some text")
	@ko = Factory.create(:language, :name => "korean", :short => "ko")
      end

      should "have its body translated one paragraph at a time" do
	post = Factory.build(:post, :language => @ko)
        content = post.para_translate(@orig.content, @en.short, @ko.short)
	assert_not_nil content
      end	

      should "have its contents translated" do
	post = Factory.build(:post, :language => @ko)
	post.prep(@ko.id, @orig)

	assert_not_nil post.title
	assert_not_nil post.content
      end
    end
  end

  context "Existing Post" do
    setup do
      @orig = Factory.create(:orig)
      @user = Factory.create(:user)
      @user2 = Factory.create(:user)
      @user3 = Factory.create(:user)
      @post = @orig.posts.new(:title => "Original Blog", :content => "Original Content", :user_id => @user_id)
      @post.save
    end

    should "create a new version when title or content is changed" do
      @post.title = "Different Title"
      @post.user_id = @user2.id
      @post.save

      assert_equal "Different Title", @post.title
      assert_equal 2, @post.version
      assert_equal @user2.id, @post.user_id
      
      @post.content = "Different Content"
      @post.user_id = @user3.id
      @post.save

      assert_equal "Different Content", @post.content
      assert_equal 3, @post.version
      assert_equal @user3.id, @post.user_id

      @post.revert_to(1)
      assert_equal 1, @post.version
      assert_equal "Original Blog", @post.title
      assert_equal @user.id, @post.user_id

      @post.revert_to(2)
      assert_equal 2, @post.version
      assert_equal "Original Content", @post.content
      assert_equal @user2.id, @post.user_id
    end

    should "not create a new version when title or content is not changed" do
      @post.user_id = @user2.id
      @post.save
      assert_equal 1, @post.version

      @post.author = "John Doe"
      @post.save
      assert_equal 1, @post.version
    end

    should "and previous versions should be rated separately" do
      # Version 2
      @post.title = "Different Title"
      @post.save
      assert_equal 2, @post.version

      # Version 3
      @post.content = "Different Content"
      @post.save
      assert_equal 3, @post.version

      @post.revert_to(2)
      assert_equal 2, @post.version
      @post.rate 5, @user2
      assert_equal 2, @post.version
      assert_equal 5, @post.rated_total

      @post.revert_to(1)
      assert_equal 1, @post.version
      @post.rate 4, @user2
      assert_equal 1, @post.version
      assert_equal 4, @post.rated_total

      @post.revert_to(2)
      assert_equal 5, @post.rated_total
    end

    should "not be rated more than once by the same user" do
      @post.rate(5, @user)
      assert 5, @post.rated_total

      @post.rate(5, @user)
      assert 5, @post.rated_total

      @post.rate(5, @user2)
      assert 10, @post.rated_total
    end
  end

end
