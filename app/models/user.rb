class User < ActiveRecord::Base

  acts_as_rated :with_stats_table => true, :no_rater => true

  has_many :posts
  has_many :origs

  validates_presence_of :username, :email
  validates_uniqueness_of :username, :case_sensitive => false
  validates_uniqueness_of :email, :case_sensitive => false

  def self.top(num=5)
    user_cols = User.column_names.collect {|c| "users.#{c}"}.join(",")
    return User.find_by_sql("SELECT #{user_cols}, count(posts.id) AS post_count FROM users LEFT OUTER JOIN posts ON posts.user_id = users.id GROUP BY users.id, #{user_cols} ORDER BY post_count DESC LIMIT #{num}")
  end

  #find the user in the database by the facebook user id
  def self.find_by_fb_user(fb_user)
    User.find_by_fb_user_id(fb_user.uid)
  end

  #Take the data returned from facebook and create a new user from it.
  #We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
  #If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
  def self.create_from_fb_connect(fb_user)
    new_facebooker = User.new(:username => "fb_#{fb_user.uid}", :email => "")
    new_facebooker.fb_user_id = fb_user.uid.to_i

    #Force save and ask user to enter username and email
    new_facebooker.save(false)
    new_facebooker
  end

  def facebook_user?
    return !fb_user_id.nil? && fb_user_id > 0
  end

end
