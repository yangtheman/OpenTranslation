class UsersController < ApplicationController

  def edit
	  @user = @current_user
  end

  def update
          debugger
	  @current_user.update_attributes(params[:user])
	  redirect_to posts_path
  end
  
  def index
    @users = User.find(:all)
  end

end
