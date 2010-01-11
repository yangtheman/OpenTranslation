require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should_have_many :posts
  should_have_many :origs

  context "New user" do
    setup do
      @user1 = Factory.create(:user)
    end

    should "be created if no other has the same username or password" do
      assert @user1.valid?
    end

    should "not be created when username is blank" do
      user2 = Factory.build(:user, :username => nil)
      assert !user2.valid?
      assert !user2.save
    end

    should "not be created when email is blank" do
      user2 = Factory.build(:user, :email => nil)
      assert !user2.valid?
      assert !user2.save
    end

    should "not be created if username already exists" do
      user2 = Factory.build(:user, :username => @user1.username)
      assert !user2.valid?
      assert !user2.save
    end

    should "not be created if email already exists" do
      user2 = Factory.build(:user, :email => @user1.email)
      assert !user2.valid?
      assert !user2.save
    end

    should "be able to be rated by other users" do
      user2 = Factory.create(:user)
      #@user1.rate(5, user2)
    end
  end

  context "New user with FB user id" do
    setup do
      @user1 = Factory.create(:user)
      @user2 = Factory.create(:user, :fb_user_id => "1234")
    end

    should "return true when fb_id is searched" do
      assert @user2.facebook_user?
      assert !@user1.facebook_user?
    end

    should "be found with right fb_user_id" do
      fb_user = stub("User", :uid => @user2.fb_user_id, :email_hashes => "someemailhash") 
      user = User.find_by_fb_user(fb_user)
      assert_equal @user2.username, user.username
    end

    should "not be found without right fb_user_id" do
      fb_user = stub("User", :uid => "1231243", :email_hashes => "someemailhash") 
      user = User.find_by_fb_user(fb_user)
      assert_nil user
    end

    should "be created if no other user with the same id exists" do
      fb_user = stub("User", :uid => "12315", :email_hashes => "someemailhash") 
      assert User.create_from_fb_connect(fb_user)
      user = User.find_by_fb_user(fb_user) 
      assert_not_nil user
      
      assert_equal user.username, "fb_#{fb_user.uid}"
      assert_equal user.fb_user_id, fb_user.uid.to_i
    end
  end

end
