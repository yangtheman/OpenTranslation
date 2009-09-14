class PostsController < ApplicationController

  uses_yui_editor

  def index
    	  @the_url = params[:url]
	  @languages = Language.find(:all, :order => "language ASC")
	  @posts = Post.find(:all, :order => "updated_at DESC")
  end

  def create 
	  @post = Post.new
	  
	  @post.url = params[:url]
	  @post.origin_id = params[:post][:origin_id]
	  @post.ted_id = params[:post][:ted_id]
	  if @post.origin_id == @post.ted_id
		  flash[:error] = 'Cannot translate from and to the same language.'
		  render :action => "index"
	  end
	  
	  from = Language.find_by_id(params[:post][:origin_id]).short
	  to = Language.find_by_id(params[:post][:ted_id]).short

	  web = Hpricot(open(@post.url))

          @post.title = web.at("title").inner_text
	  ted_title = Translate.t(@post.title, from, to)

          #remove all images (shall I or not?)
	  #web.search("img").remove
	                    
	  #Wordpress's main body has "entry" div id
	  body = web.search("div.entry/p")
	  if body.inner_text.length == 0
	  	body = web.search("/html/body//p")
	  end
	  #body = web.search("/html/body/")

	  @post.content = body.to_html
	  #ted_content = ""
	  #body.each do |p|
		  #ted_content += Translate.t(cleanup(p.to_html), from, to)
	  #end

	  if @post.save
		  @post.title = ted_title
		  @post.content = translate(body, from, to)
		  render :action => "edit"
	  else 
		  flash[:error] = 'Oops! Something happened! Same article perhaps?'
		  redirect_to posts_path
	  end
  end

  def add_trans
	  @post = Post.find(params[:id])
	  original_post = @post.versions.earliest

	  from = @post.orig_lang.short
	  @post.ted_id = params[:post][:ted_id]
	  to = Language.find_by_id(params[:post][:ted_id]).short

	  @post.title = Translate.t(original_post.title, from, to)
	  @post.content = translate(Hpricot(original_post.content).search("/p"), from, to)

	  render :action => "edit"
  end

  def edit
	  @post = Post.find(params[:id])
  end

  def update
	  @post = Post.find(params[:id])
	  if @post.update_attributes(params[:post])
		  redirect_to post_path(@post)
	  else 
		  render :action => "edit"
	  end
  end

  def show
	  @post = Post.find(params[:id])
	  if params[:version] 
		  @post.revert_to(params[:version])
	  end
	  @original_post = @post.versions.earliest
	  @languages = Language.find(:all, :order => "language ASC")
  end
end
