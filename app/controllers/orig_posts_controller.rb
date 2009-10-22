class OrigPostsController < ApplicationController
  
  def index
    @origs = OrigPost.find(:all, :order => 'created_at DESC')
  end
  
  def show
    @orig = OrigPost.find(params[:id])
    @posts = @orig.posts.find(:all)
  end

end
