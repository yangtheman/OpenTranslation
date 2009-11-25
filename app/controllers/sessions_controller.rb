class SessionsController < ApplicationController

  protect_from_forgery :except => [:create, :add_openid, :openid_reg]

  def new
  end

  def create
    #Begin OpenID authentication
    openid_url = params[:openid_url]
    open_id_authentication
  end

  def destroy
    if @current_user.facebook_user?
      clear_fb_cookies!
      clear_facebook_session_information
    end
    session[:user_id] = nil
    @current_user = false
    redirect_to(root_url)
  end

  #MERGE: Add openid_url to exisitng user
  def add_openid
    if @current_user = User.find_by_username(params[:user_id])
      @current_user.openid_url = params[:openid_url]
      @current_user.save
      successful_login
    else
      redirect_to "#{params[:clickpass_merge_callback_url]}?userid_authenticated=false"
    end
  end

  #NEW
  def openid_reg
    @current_user = User.new
    #if User.find_by_username(params[:nickname]) || User.find_by_email(params[:email])
      #failed_login("Userrname or email is already taken!")
    #end
    @current_user.username = params[:nickname]
    @current_user.email = params[:email]
    @current_user.openid_url = params[:clickpass_openid]

    #Force save
    @current_user.save
    successful_login
  end

  # Log-in method for fb users
  def fb_login
    if @current_user.nil?
      #User not in db
      User.create_from_fb_connect(facebook_session.user)
      user = User.find_by_fb_user(facebook_session.user)
      redirect_to edit_user_path(user)
    else
      #User in db
      if @current_user.fb_user_id == facebook_session.user.id
	redirect_to :back
      else 
	redirect_to new_session_path
      end
    end
  end

  protected
  def open_id_authentication
    authenticate_with_open_id do |result, openid_url|
      if result.successful?
        if @current_user = User.find_by_openid_url(openid_url)
	  successful_login
	else
	  #If users is not found based on OpenID, Clickpass will ask your if new account should be opened or merged
	  #Development Server      
	  #redirect_to "http://www.clickpass.com/process_new_openid?site_key=CNxswsAO8P&process_openid_registration_url=http%3A%2F%2F127.0.0.1%3A3000%2Fsessions%2Fopenid_reg&requested_fields=nickname%2Cemail&required_fields=&nickname_label=Nickname&email_label=Email"
	  #Production Server
	  redirect_to "http://www.clickpass.com/process_new_openid?site_key=rzMQEOe8gQ&process_openid_registration_url=http%3A%2F%2Falpha.bloglation.com%2Fsession%2Fopenid_reg&site_name=Bloglation&requested_fields=nickname%2Cemail&required_fields=&nickname_label=Nickname&email_label=Email"
	end
      else
        failed_login result.message
      end
    end
  end

  private
  def successful_login
    session[:user_id] = @current_user.id
    redirect_to(root_url)
  end
  
  def failed_login(message)
    flash[:error] = message
    redirect_to(new_session_url)
  end
end
