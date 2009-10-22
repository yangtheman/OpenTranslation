module UsersHelper
          def rating_links(user)
                average = (user.rating_average.blank? ? 0 : user.rating_average) * 100 / 5
                html = "<ul class = 'stars'>"
                html += "<li class = 'current_rating' style ='width: #{average}%'>#{average}%</li>"
                if !@current_user.nil? && !user.rated_by?(@current_user) && user.id != @current_user.id
                        html += "<li>#{link_to_remote "One", :update => "user_rating_#{user.id}", :url => rate_post_path(user, :rating => 1), :html => {:class => "one_star"}, :method => :put}</li>"
                        html += "<li>#{link_to_remote "Two", :update => "user_rating_#{user.id}", :url => rate_post_path(user, :rating => 2), :html => {:class => "two_stars"}, :method => :put}</li>"
                        html += "<li>#{link_to_remote "Three", :update => "user_rating_#{user.id}", :url => rate_post_path(user, :rating => 3), :html => {:class => "three_stars"}, :method => :put}</li>"
                        html += "<li>#{link_to_remote "Four", :update => "user_rating_#{user.id}", :url => rate_post_path(user, :rating => 4), :html => {:class => "four_stars"}, :method => :put}</li>"
                        html += "<li>#{link_to_remote "Five", :update => "user_rating_#{user.id}", :url => rate_post_path(user, :rating => 5), :html => {:class => "five_stars"}, :method => :put}</li>"
                end
                html += "</ul>"
                html += "<br /><p><i>based on #{user.rated_count} ratings</i></p>"
                html
        end
end
