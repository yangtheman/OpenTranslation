class PostsController < ApplicationController

  uses_yui_editor

  def index
	  @languages = Language.find(:all, :order => "language ASC")
	  @posts = Post.find(:all, :order => "created_at DESC")
  end

  def create 
	  @post = Post.new
	  
	  @post.url = params[:url]
	  @post.origin_id = params[:post][:origin_id]
	  @post.ted_id = params[:post][:ted_id]
	  if @post.origin_id == @post.ted_id
		  render :action => "index"
	  end

	  from = Language.find_by_id(params[:post][:origin_id]).short
	  to = Language.find_by_id(params[:post][:ted_id]).short

	  web = Hpricot(open(@post.url))

	  #remove all images (shall I or not?)
	  #web.search("img").remove

          @post.title = web.at("title").inner_text
	  ted_title = Translate.t(@post.title, from, to)
          
	  @post.content = ""
	  ted_content = ""
          
	  #Wordpress's main body had "entry" div id
	  body = web.search("div.entry/p")
          if body.inner_text.length == 0
		  body = web.search("/html/body//p")
	  end
          #body = web.search("/html/body/")
	  
	  body.each do |p|
		  @post.content += p.to_html
		  ted_content += Translate.t(cleanup(p.to_html), from, to)
	  end

	  if @post.save
		  @post.title = ted_title
		  @post.content = ted_content
		  render :action => "edit"
	  else 
		  flash[:error] = 'Oops! Something happened! Same article perhaps?'
		  redirect_to posts_path
	  end
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
