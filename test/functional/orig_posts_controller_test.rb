require 'test_helper'

class OrigsControllerTest < ActionController::TestCase

  context "On GET to :index" do
    setup do
      5.times do
	Factory.create(:orig)
      end

      get :index
    end

    should_assign_to :origs
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash

    should "display all original posts" do
       assert_not_equal 0, assigns(:origs).size
    end
  end

  context "On GET to :show" do
    setup do 
      @orig = Factory.create(:orig)
      @ko = Factory.create(:language, :name => "korean", :short => "ko")
      5.times do
	Factory.create(:post, :language => @ko, :orig => @orig)
      end
      get :show, :id => @orig.id 
    end

    should_assign_to :orig
    should_respond_with :success
    should_render_template :show
    should_not_set_the_flash

    should "display original post with the id" do
      assert_equal @orig.id, assigns(:orig).id
      assert_equal 5, assigns(:orig).posts.size
    end
  end

end
