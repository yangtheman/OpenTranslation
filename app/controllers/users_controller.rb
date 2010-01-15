class UsersController < ApplicationController

  before_filter :login_required, :except => [:show, :index]

  def show
    @user = User.find(params[:id])
    @posts = @user.posts.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end

  def edit
    @user = @current_user
  end

  def update
    @current_user.update_attributes(params[:user])
    redirect_to root_url
  end
  
  def index
    @users = User.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end

end
