class WelcomeController < ApplicationController

  def index
    #@the_url = params[:url]
    @languages = Language.all
    @top_posts = Post.top
    @top_origs = Orig.top
    @top_users = User.top
  end

  def allposts
    @posts = Post.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end

end
