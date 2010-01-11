module PostsHelper
  def rating_links(orig, post)
    average = (post.rating_average.blank? ? 0 : post.rating_average) * 100 / 5
    html = "<ul class = 'stars'>"
    html += "<li class = 'current_rating' style ='width: #{average}%'>#{average}%</li>"
    if logged_in? && !post.rated_by?(@current_user) && post.user_id != @current_user.id 
      html += "<li>#{link_to_remote "One", :update => "post_rating_#{post.id}", :url => rate_orig_post_path(orig, post, :rating => 1), :html => {:class => "one_star"}, :method => :put}</li>"
      html += "<li>#{link_to_remote "Two", :update => "post_rating_#{post.id}", :url => rate_orig_post_path(orig, post, :rating => 2), :html => {:class => "two_stars"}, :method => :put}</li>"
      html += "<li>#{link_to_remote "Three", :update => "post_rating_#{post.id}", :url => rate_orig_post_path(orig, post, :rating => 3), :html => {:class => "three_stars"}, :method => :put}</li>"
      html += "<li>#{link_to_remote "Four", :update => "post_rating_#{post.id}", :url => rate_orig_post_path(orig, post, :rating => 4), :html => {:class => "four_stars"}, :method => :put}</li>"
      html += "<li>#{link_to_remote "Five", :update => "post_rating_#{post.id}", :url => rate_orig_post_path(orig, post, :rating => 5), :html => {:class => "five_stars"}, :method => :put}</li>"
    end
    html += "</ul>"
    html += "<br /><p><i>based on #{post.rated_count} ratings</i></p>"
    html
  end

  def tweetthis(orig, post)
    twitter_title = orig.title.gsub(/[ \t]+/, '+') # change to twitter-friendly title                   
    url = "http://alpha.bloglation.com/posts/#{post.id}?version=#{post.version}"
    url = ( ShortURL.shorten(url) rescue nil ) || url
    "http://www.twitter.com/home/?status=Just+translated+to+#{post.language.name}!+-+#{twitter_title}+#{url}"
  end

end
