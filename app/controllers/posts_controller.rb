class PostsController < ApplicationController

  def index
	  #@post = Post.new
	  @languages = Language.find(:all, :order => "language ASC")
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
          @post.title = web.at("title").inner_text
          
	  content = ""
	  ted_content = ""
          
	  body = web.search("/html/body//p")
          if body.inner_text.length < 1
            body = web.search("/html/body/")
	  end
	  
	  body.each do |p|
	    content += "#{p.inner_text} \n"
	    ted_content += Translate.t(p.inner_text, from, to)
	  end
	  @post.content = content
	  ted_title = Translate.t(@post.title, from, to)

	  if @post.save
		  @post.title = ted_title
		  @post.content = ted_content
		  render :action => "edit"
		  #if @post.update_attribute(:title, ted_title) && @post.update_attribute(:content, ted_content) 
			  #redirect_to edit_post_path(@post) 
		  #else 
			  #render :action => "index"
		  #end
	  else 
		  render :action => "index"
	  end
  end


  def edit
	  @post = Post.find(params[:id])
	  #@original_post = @post.versions.earliest
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
	  @original_post = @post.versions.earliest
	  if params[:version] 
		  @post = revert_to(params[:version])
	  end
  end
end
