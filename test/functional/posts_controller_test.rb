require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  def getready
    @request.env['HTTP_USER_AGENT'] = "Firefox"
    @current_user = Factory.create(:user)
    @controller.stubs(:session).returns({:user_id => @current_user.id})
    @en = Factory.create(:language, :id => 1, :short => 'en', :name => 'English')
    @ko = Factory.create(:language, :id => 10, :short => 'ko', :name => 'Korean')
    @oldorig = Factory.create(:orig, :origin_id => 1)
    @oldpost = Factory.create(:post, :ted_id => 10, :orig => @oldorig)
    @neworig = Factory.create(:orig, :origin_id => 1)
    @newpost = Factory.create(:post, :ted_id => 10, :orig => @neworig)
    Orig.stubs(:new).returns(@neworig)
    Post.stubs(:new).returns(@newpost)
    #@controller.stubs(:find_orig_post).returns(@neworig)
  end

  context "On GET to :new with no post parameter" do
    setup do
      getready
      get :new, :post => {}
    end

    should_redirect_to("Root URL") {root_url}
    #should_set_the_flash_to "Input parameters are empty."
  end

  context "On GET to :new with the same origin and ted ids" do
    setup do
      getready
      get :new, :post => {:url => "http://www.google.com", :origin_id => 1, :ted_id => 1}
    end

    should_redirect_to("Root URL") {root_url}
    #should_set_the_flash_to "Cannot translate from and to the same language."
  end

  context "On GET to :new with non-existing URL" do
    setup do
      getready
      @neworig.expects(:newentry).returns(true)
      @newpost.expects(:prep).returns(true)
      get :new, :url => "http://www.google.com", :post => {:origin_id => 1, :ted_id => 10}
    end

    should_assign_to :orig
    should_assign_to :post
    should_render_template :new

    should "create orig and post" do
      assert_equal @neworig.id, assigns(:orig).id
      assert_equal @newpost.id, assigns(:post).id
    end
  end

  context "On GET to :new with existing URL and existing translation" do
    setup do
      getready
      get :new, :url => @oldorig.url, :post => {:origin_id => 1, :ted_id => 10}
    end  

    should_assign_to :orig
    should_assign_to :post
    should_render_template :edit

    should "find the existing orig and post" do
      assert_equal @oldorig.id, assigns(:orig).id
      assert_equal @oldpost.id, assigns(:post).id
    end
  end

  context "On GET to :new with existing URL but no existing translation" do
    setup do
      getready
      @newpost.expects(:prep).returns(true)
      get :new, :url => @oldorig.url, :post => {:origin_id => 1, :ted_id => 11}
    end

    should_assign_to :orig
    should_assign_to :post
    should_render_template :new

    should "find the orig post and create new post" do
      assert_equal @oldorig.id, assigns(:orig).id 
      assert_equal @newpost.id, assigns(:post).id
    end
  end    

  context "On GET to :new with existing URL but no existing translation and with non-supported translation" do
    setup do
      getready
      @newpost.expects(:prep).returns(false)
      get :new, :url => @oldorig.url, :post => {:origin_id => 1, :ted_id => 11}
    end

    #should_set_the_flash_to "Translation not supported yet."
    should_redirect_to("Root URL") { root_url }
  end    

  context "On GET to :new with no session" do
    setup do
      getready
      @controller.stubs(:session).returns({:user_id => nil})
      get :new, :url => "http://www.google.com", :post => {:origin_id => 1, :ted_id => 10}
    end

    should_redirect_to("New session creation") { new_session_path }
  end

  context "On POST to :create with successful save" do
    setup do
      getready
      @newpost.expects(:save).returns(true)
      post :create, :orig_id => @oldorig.id, :post => {:title => "some title", :content => "some content"}
    end

    should_assign_to :orig
    should_assign_to :post
    should_redirect_to("Post Show page") { orig_post_path(assigns(:orig), assigns(:post)) }

    should "have current user's id as user_id" do
      assert_equal @current_user.id, assigns(:post).user_id
    end
  end

  context "On POST to :create with failed save" do
    setup do
      getready
      @newpost.expects(:save).returns(false)
      post :create, :orig_id => @oldorig.id, :post => {:title => "some title", :content => "some content"}
    end

    should_assign_to :orig
    should_assign_to :post
    should_render_template :new
    #should_set_the_flash_to "Save failed."
  end 

  context "On POST to :add_trans with the same origin and ted_id" do
    setup do
      getready
      @request.env['HTTP_REFERER'] = "http://blah.com/"
      post :add_trans, :orig_id => @oldorig.id, :post => {:ted_id => 1}
    end

    should_assign_to :orig
    #should_set_the_flash_to "Cannot translate to the same language!"
    should_redirect_to("Previous page") {"http://blah.com/"}
  end

  context "On POST to :add_trans with the existing ted_id" do 
    setup do
      getready
      post :add_trans, :orig_id => @oldorig.id, :post => {:ted_id => 10}
    end

    should_assign_to :orig
    should_assign_to :post
    should_redirect_to("Edit Page") { edit_orig_post_path(assigns(:orig), assigns(:post)) }
  end

  context "On POST to :add_trans with non-existing ted_id" do
    setup do
      getready
      @newpost.expects(:prep).returns(true)
      post :add_trans, :orig_id => @oldorig.id, :post => {:ted_id => 9}
    end

    should_assign_to :orig 
    should_assign_to :post
    should_render_template :new
  end

  context "On POST to :add_trans with non-existing ted_id with unsupported translation" do
    setup do
      getready
      @newpost.expects(:prep).returns(false)
      @request.env['HTTP_REFERER'] = "http://blah.com/"
      post :add_trans, :orig_id => @oldorig.id, :post => {:ted_id => 9}
    end

    should_assign_to :orig 
    should_assign_to :post
    #should_set_the_flash_to "Translation not supported yet."
    should_redirect_to("Previous Page") { "http://blah.com/" }
  end

  context "On GET to :edit" do
    setup do
      getready
      get :edit, :orig_id => @oldorig.id, :id => @oldpost.id
    end

    should_assign_to :orig
    should_assign_to :post
    should_render_template :edit
  end
  
  context "On PUT to :update with successful update_attributes" do
    setup do
      getready
      Post.any_instance.expects(:update_attributes).returns(true)
      put :update, :orig_id => @oldorig.id, :id => @oldpost.id, :post => {:title => "some title", :content => "some content"}
    end

    should_assign_to :orig
    should_assign_to :post
    should_redirect_to("Post Show page") { orig_post_path(assigns(:orig), assigns(:post)) }

    should "find the right original post and translated post" do
      assert_equal @oldpost.id, assigns(:post).id
    end
  end

  context "On PUT to :update with failed update_attributes" do
    setup do
      getready
      Post.any_instance.expects(:update_attributes).returns(false)
      put :update, :orig_id => @oldorig.id, :id => @oldpost.id, :post => {:title => "some title", :content => "some content"}
    end

    should_assign_to :orig
    should_assign_to :post
    should_render_template :edit
  end

  context "On GET to :show with an id" do
    setup do
      getready
      get :show, :orig_id => @oldorig.id, :id => @oldpost.id
    end

    should_assign_to :orig, :post, :ted_user, :languages
    
    should "get the right original post and its child post" do
      assert_equal @oldorig.id, assigns(:orig).id
      assert_equal @oldpost.id, assigns(:post).id
    end
  end

  context "On PUT to :rate on a post" do
    setup do
      getready
      Post.any_instance.expects(:rate).returns(true)
      put :rate, :orig_id => @oldorig.id, :id => @oldpost.id, :rating => 1
    end

    should_render_partial :_post_rating
  end

end
