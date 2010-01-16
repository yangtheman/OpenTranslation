class OrigsController < ApplicationController
  
  def index
    @origs = Orig.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end
  
  def show
    @orig = Orig.find(params[:id])
    @posts = @orig.posts.find(:all, :order => "updated_at DESC")
    @languages = Language.all_ordered
  end

end
