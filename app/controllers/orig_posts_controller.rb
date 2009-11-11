class OrigPostsController < ApplicationController
  
  def index
    #@origs = OrigPost.find(:all, :order => 'created_at DESC')
    @origs = OrigPost.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end
  
  def show
    @orig = OrigPost.find(params[:id])
    @posts = @orig.posts.find(:all, :order => "updated_at DESC")
    @languages = Language.find(:all, :order => "language ASC")
  end

end
