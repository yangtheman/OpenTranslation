class PostsController < ApplicationController
  
  uses_yui_editor
  local_addresses.clear

  before_filter :login_required, :except => [:index, :show, :search]

  require 'hpricot'
  require 'open-uri'
  require 'rtranslate'

  def exception
    raise(Exception, "Forced Exception from NodesController")
  end

  def index
    @the_url = params[:url]
    @languages = Language.find(:all, :order => "language ASC")
    @posts = Post.find(:all, :order => "created_at DESC", :limit => 5)

    orig_cols = OrigPost.column_names.collect {|c| "orig_posts.#{c}"}.join(",")
    @top_origs = OrigPost.find_by_sql("SELECT #{orig_cols}, count(posts.id) AS post_count FROM orig_posts LEFT OUTER JOIN posts ON posts.orig_post_id = orig_posts.id GROUP BY orig_posts.id, #{orig_cols} ORDER BY post_count DESC LIMIT 5")

    user_cols = User.column_names.collect {|c| "users.#{c}"}.join(",")
    @top_users = User.find_by_sql("SELECT #{user_cols}, count(posts.id) AS post_count FROM users LEFT OUTER JOIN posts ON posts.user_id = users.id GROUP BY users.id, #{user_cols} ORDER BY post_count DESC LIMIT 5")
	  
  end

  def new
    @orig = OrigPost.find_by_url(params[:url])

    # New translation
    if @orig.nil?
      @orig = OrigPost.new
      @orig.url = params[:url]
      @orig.origin_id = params[:post][:origin_id]
      @orig.user_id = @current_user.id
      if @orig.origin_id == params[:post][:ted_id]
        flash[:error] = 'Cannot translate from and to the same language.'
        render :action => "index"
      end
      from = Language.find_by_id(params[:post][:origin_id]).short

      web = Hpricot(open(@orig.url))

      @orig.title = web.at("title").inner_text

      #remove all images (shall I or not?)
      #web.search("img").remove
	                    
      #Wordpress's main body has "entry" div id
      body = web.search("div.entry/p")
      if body.inner_text.length == 0
	body = web.search("/html/body//p")
      end
      #body = web.search("/html/body/")

      @orig.content = body.to_html
      #ted_content = ""
      #body.each do |p|
        #ted_content += Translate.t(cleanup(p.to_html), from, to)
      #end

      if !@orig.save
        flash[:error] = 'Oops! Something happened! Same article perhaps?'
        redirect_to posts_path
      else
        @post = @orig.posts.new
      end
    elsif @post = Post.find_by_orig_post_id_and_ted_id(@orig.id, params[:post][:ted_id])
      #Original exists and target language was already done before.
      render :action => "edit"
    else
      #Original exists, but target language was not done before.
      @post = @orig.posts.new
      from = @orig.orig_lang.short
      body = Hpricot(@orig.content).search("/p")
    end

    to = Language.find_by_id(params[:post][:ted_id]).short

    @post.title = Translate.t(@orig.title, from, to)
    @post.content = translate(body, from, to)
    @post.ted_id = params[:post][:ted_id] 
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
    if @post = @orig.posts.find_by_ted_id(params[:post][:ted_id])
      flash[:error] = "Translation already exists"
      redirect_to post_path(@post)
    else 
      @post = @orig.posts.new
    end

    from = @orig.orig_lang.short
    @post.ted_id = params[:post][:ted_id]
    to = Language.find(@post.ted_id).short

    @post.title = Translate.t(@orig.title, from, to)
    @post.content = translate(Hpricot(@orig.content).search("/p"), from, to)

    render :action => "new"
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
    @twitterurl = tweetthis(@post)
  end

  def rate
    post = Post.find(params[:id])
    if post.user_id == @current_user.id 
      flash[:error] = "You cannot rate yourself!"
      redirect_to post_path(post)
    else
      #user = User.find(post.user_id) 
      #user.rate(params[:rating].to_i, @current_user) 
      post.rate(params[:rating].to_i, @current_user) if !post.rated_by?(@current_user)
      #redirect_to post_path(post)
    end
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

  #Expects two parameters. :url is URL of a blog. :target is target language in two-letter form such as "en" for English
  def external_request
    url = params[:url]
    to = params[:target]
    ted_id = Language.find_by_short(to).id

    post = Post.find_by_url(url)
    if post 
      #Target translation exists
      if post.versions.find_by_ted_id(ted_id)
      	version = post.versions.find_by_ted_id(ted_id).version
	if version == 1
	  version += 1
      	end
	post.revert_to(version)
	@title = post.title
	@content = post.content
      else
	#A translation has been done, but target translation does not exist
      	post.revert_to('1')
	from = post.orig_lang.short
      	@title = Translate.t(post.title, from, to)
      	@content = translate(Hpricot(post.content).search("/p"), from, to)
      end
    else
      #No translation has ever been done
      @post = Post.new
      @post.url = url
      @post.ted_id = ted_id

      web = Hpricot(open(url))
      @post.title = web.at("title").inner_text
      from = Detection.detect(@post.title)
      @post.origin_id = Language.find_by_short(from).id

      if @post.origin_id == @post.ted_id
	flash[:error] = 'Cannot translate from and to the same language.'
	#Send error message
      end

      #Wordpress's main body has "entry" div id
      body = web.search("div.entry/p")
      if body.inner_text.length == 0
	body = web.search("/html/body//p")
      end
      @post.content = body.to_html

      #Save version 1 first.
      if @post.save 
	@title = Translate.t(@post.title, from, to)
	@content = translate(body, from, to)
      else 
	#Send error message
      end
    end
    #Send translated contents over...post.id, post.title, post.content
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
