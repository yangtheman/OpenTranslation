require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  context "On GET to :index" do
    setup do
      @en = Factory.create(:language, :id => 1, :short => 'en', :name => 'English')
      @ko = Factory.create(:language, :id => 10, :short => 'ko', :name => 'Korean')
      @langs, @users, @origs, @posts = [], [], [], []
      10.times do
	@langs << Factory.create(:language)
	user = Factory.create(:user)
	@users << user
	orig = Factory.create(:orig, :origin_id => @en.id)
	@origs << orig
	post = Factory.create(:post, :ted_id => @ko.id, :orig_id => orig, :user_id => user.id)
	@posts << post
      end
      Language.expects(:all_ordered).returns(@langs)
      Orig.expects(:top).returns(@origs)
      Post.expects(:top).returns(@posts)
      User.expects(:top).returns(@users)
      Orig.any_instance.stubs(:post_count).returns('10')
      Post.any_instance.stubs(:post_count).returns('10')
      User.any_instance.stubs(:post_count).returns('10')

      get :index
    end

    should_assign_to :languages, :top_posts, :top_origs, :top_users
    should_render_template :index
  end

  context "On GET to :showposts" do
    setup do
      @en = Factory.create(:language, :id => 1, :short => 'en', :name => 'English')
      @posts = []
      10.times do
	@posts << Factory.create(:post, :ted_id => @en.id)
      end
      get :allposts
    end

    should_assign_to :posts
    should_render_template :allposts

    should "show all posts" do
      assert_not_equal 0, @posts.size
    end
  end

end
