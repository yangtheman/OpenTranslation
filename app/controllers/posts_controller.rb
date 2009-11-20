class PostsController < ApplicationController
  
  uses_yui_editor
  #local_addresses.clear

  before_filter :check_browser, :login_required, :except => [:index, :show, :search]

  require 'hpricot'
  require 'rtranslate'

  #def exception
  #  raise(Exception, "Forced Exception from NodesController")
  #end

  def index
    @the_url = params[:url]
    @languages = Language.find(:all, :order => "language ASC")
    @posts = Post.find(:all, :order => "created_at DESC", :limit => 5)

    @top_origs = OrigPost.top(5)
    @top_users = User.top(5)
	  
  end

  def new
    if params[:post][:origin_id] == params[:post][:ted_id]
      flash[:error] = 'Cannot translate from and to the same language.'
      render :action => "index"
    end

    # Original post exist?
    @orig = OrigPost.find_by_url(params[:url])

    # New translation
    if @orig.nil?
      @orig = OrigPost.newentry(@current_user, params)
    #Original exists and target language was already translated before.
    elsif @post = Post.find_by_orig_post_id_and_ted_id(@orig.id, params[:post][:ted_id])
      render :action => "edit"
    end

    @post = @orig.posts.new

    from = @orig.orig_lang.short
    to = Language.find_by_id(params[:post][:ted_id]).short

    # Refactor this
    @post.title = Translate.t(@orig.title, from, to)
    # Capture the error message 
    if @post.title =~ /^Error\: Translation from.*supported yet\!/
      flash[:error] = "#{@post.title}"
      redirect_to(root_url)
    else 
      @post.content = translate(Hpricot(@orig.content).search("/p"), from, to)
      @post.ted_id = params[:post][:ted_id] 
    end
  end

  def create
    @orig = OrigPost.find(params[:post][:orig_post_id])
    @post = @orig.posts.new(params[:post])
    @post.user_id = @current_user.id
    if @post.save
      redirect_to post_path(@post)
    else
      flash[:error] = "Save failed"
      render :action => "new"
    end
  end

  def add_trans
    @orig = OrigPost.find(params[:orig_post_id])
    # Trying to translate to original language
    if @orig.origin_id.to_s == params[:post][:ted_id] 
      flash[:error] = "Cannot translate to the same language!"
      redirect_to :back
    # Tranlsation already exists
    elsif post = @orig.posts.find_by_ted_id(params[:post][:ted_id])
      flash[:error] = "Translation already exists!"
      redirect_to post_path(post)
    else 	
      @post = @orig.posts.new
      from = @orig.orig_lang.short
      @post.ted_id = params[:post][:ted_id]
      to = Language.find(@post.ted_id).short

      # Refactor this
      @post.title = Translate.t(@orig.title, from, to)
      if @post.title =~ /^Error\: Translation from.*supported yet\!/
	flash[:error] = "#{@post.title}"
	redirect_to :back 
      else 
	@post.content = translate(Hpricot(@orig.content).search("/p"), from, to)
	render :action => "new"
      end
    end
  end

  def edit
    @post = Post.find(params[:id])
    @orig = OrigPost.find(@post.orig_post_id)
  end

  def update
    @post = Post.find(params[:id])
    @post.user_id = @current_user.id
    if @post.update_attributes(params[:post])
      if @current_user.facebook_user? && params[:fbfeed]
        flash[:user_action_to_publish] = FacebookPublisher.create_publish_tx(@post, OrigPost.find(@post.orig_post_id).title, session[:facebook_session])
      end
      redirect_to post_path(@post)
    else 
      flash[:error] = 'Update failed'
      render :action => "edit"
    end
  end

  def show
    @post = Post.find(params[:id])
    if params[:version] 
      @post.revert_to(params[:version])
    end
    @ted_user = User.find_by_id(@post.user_id)
    @original_post = OrigPost.find(@post.orig_post_id)
    @languages = Language.find(:all, :order => "language ASC")
    @current_lang = @post.target_lang.language
    @twitterurl = tweetthis(@post)
  end

  def rate
    post = Post.find(params[:id])
    #user = User.find(post.user_id) 
    #user.rate(params[:rating].to_i, @current_user) 
    post.rate(params[:rating].to_i, @current_user) if !post.rated_by?(@current_user)
    #redirect_to post_path(post)
    render :partial => "post_rating", :locals => {:post => post}
  end

  def showorig
    post = Post.find(params[:id])
    orig = OrigPost.find(post.orig_post_id)
    @posts = orig
  end

  def search
    @query=params[:query]
    @total_hits = Post.total_hits(@query)
    @posts = Post.paginate_with_ferret(@query, :page => params[:page], :per_page => 10, :order => 'updated_at DESC')
  end

  def showall 
    @posts = Post.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
  end
    
  def check_browser
    browser_type = ua_identifier(request.user_agent)
    #redirect_to browser_path if browser_type != "Firefox"
    redirect_to browser_path if !(browser_type == "Firefox" || browser_type == "Opera" || browser_type == "Safari")
  end

  class FacebookPublisher < Facebooker::Rails::Publisher
    def publish_tx_template
      one_line_story_template "{*actor*} translated/edited: {*post_title*}"
      short_story_template "{*actor*} translated/edited: <a href='http://opent.heroku.com/posts/{*post_id*}?version={*post_version*}'>{*post_title*}</a> to {*post_language*}",
			   "Read it, rate it and/or make it better. Help spread the knowledge in other cultures!"
    end

    def publish_tx(post, orig_title, facebook_session)
      send_as :user_action
      from facebook_session.user
      data :actor => facebook_session.user.first_name, :post_id => post.id, :post_title => orig_title, :post_version => post.version, :post_language => post.target_lang.language
    end
  end

end
