require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context "On GET to :show" do
    setup do
      @user = Factory.create(:user)
      get :show, :id => @user.id
    end

    should_assign_to :user
    should_render_template :show

    should "get the right user object" do
      assert_equal @user.id, assigns(:user).id
    end
  end

  context "On GET to :edit" do
    setup do
      @user = Factory.create(:user)
      @controller.stubs(:current_user).returns(@user)
      @controller.stubs(:fetch_logged_user).returns(@user)

      get :edit, :id => @user.id
    end

    #should_render_template :edit

    should "get the right user object" do
      #assert_equal @user.id, assigns(:current_user).id
    end
  end

  context "On GET to :index" do
    setup do
      @mockusers = []
      10.times do
	@mockusers << Factory.create(:user)
      end

      get :index
    end

    should_assign_to :users

    should "get all users" do
      assert_not_equal 0, assigns(:users).size
    end
  end

end
