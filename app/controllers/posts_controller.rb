class PostsController < ApplicationController

  # Need to get sending email work with Heorku
  #local_addresses.clear
  #def exception
  #  raise(Exception, "Forced Exception from NodesController")
  #end
  
  uses_yui_editor

  # Check client browser only in new and update
  before_filter :check_browser, :login_required, :except => [:index, :show, :search]
  
  def new
    unless params[:post] && params[:url]
      flash[:error] = 'Input parameters are empty.'
      redirect_to root_url and return
    end

    unless params[:post][:origin_id] != params[:post][:ted_id]
      flash[:error] = 'Cannot translate from and to the same language.'
      redirect_to root_url and return
    end

    @orig = Orig.find_by_url(params[:url])
    target_lang_id = params[:post][:ted_id]

    # Original post exist?
    if !@orig 
      # First translation ever, thus create a original entry.
      @orig = Orig.new(:origin_id => params[:post][:origin_id], 
		       :url => params[:url],
		       :user_id => @current_user.id)
      if !@orig.newentry
	flash[:error] = "Error in retrieving information about #{params[:url]}!"
	redirect_to root_url and return
      end
    elsif @post = @orig.posts.find_by_ted_id(target_lang_id)
      #Original exists and target language was already translated before.
      render :action => "edit" and return
    end

    # New translation
    @post = @orig.posts.new
    if !@post.prep(target_lang_id, @orig)
      flash[:error] = "Translation not supported yet."
      redirect_to(root_url)
    end 
  end

  def create
    @orig = Orig.find(params[:orig_id])
    @post = @orig.posts.build(params[:post])
    @post.user_id = @current_user.id

    if @post.save
      if @current_user.facebook_user? && params[:fbfeed]
        flash[:user_action_to_publish] = FacebookPublisher.create_publish_tx(@post, @orig.title, session[:facebook_session])
      end
      redirect_to([@orig, @post])
    else
      flash[:error] = "Save failed."
      render :action => "new"
    end
  end

  def add_trans
    @orig = Orig.find(params[:orig_id])
    target_lang_id = params[:post][:ted_id]

    # Refactor this
    if @orig.origin_id == params[:post][:ted_id] 
      # Trying to translate to original language
      flash[:error] = "Cannot translate to the same language!"
      redirect_to :back and return
    elsif @post = @orig.posts.find_by_ted_id(target_lang_id)
      # Tranlsation already exists, and thus bring up edit page
      redirect_to edit_orig_post_path(@orig, @post) and return
    else 	
      @post = @orig.posts.new
      if !@post.prep(target_lang_id, @orig)
	flash[:error] = "Translation not supported yet."
	redirect_to :back 
      else 
	render :action => "new"
      end
    end
  end

  def edit
    @orig = Orig.find(params[:orig_id])
    @post = @orig.posts.find(params[:id])
  end

  def update
    @orig = Orig.find(params[:orig_id])
    @post = @orig.posts.find(params[:id])
    @post.user_id = @current_user.id

    if @post.update_attributes(params[:post])
      if @current_user.facebook_user? && params[:fbfeed]
        flash[:user_action_to_publish] = FacebookPublisher.create_publish_tx(@post, @orig.title, session[:facebook_session])
      end
      redirect_to([@orig, @post])
    else 
      flash[:error] = 'Update failed'
      render :action => "edit"
    end
  end

  def show
    @orig = Orig.find(params[:orig_id])
    @post = @orig.posts.find(params[:id])
    if params[:version] 
      @post.revert_to(params[:version])
    end

    @prevs = @post.versions
    @ted_user = User.find(@post.user_id)
    @languages = Language.all
  end

  def rate
    @orig = Orig.find(params[:orig_id])
    @post = @orig.posts.find(params[:id])
    if params[:version] 
      @post.revert_to(params[:version])
    end

    #user = User.find(@post.user_id) 
    #user.rate(params[:rating].to_i, @current_user) 
    @post.rate(params[:rating].to_i, @current_user) if !@post.rated_by?(@current_user)
    #redirect_to post_path(post)
    render :partial => "post_rating", :locals => {:orig => @orig, :post => @post}
  end

  def search
    debugger
    @query = params[:query]
    @posts = Post.search(@query)
    #@posts = results.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
    #@total_hits = Post.total_hits(@query)
    #@posts = Post.paginate_with_ferret(@query, :page => params[:page], :per_page => 10, :order => 'updated_at DESC')
  end
   
  def check_browser
    browser_type = ua_identifier(request.user_agent)
    redirect_to browser_path if browser_type == "Internet Explorer"
  end

end
