class FacebookPublisher < Facebooker::Rails::Publisher
  def publish_tx_template
    one_line_story_template "{*actor*} translated/edited: {*post_title*}"
    short_story_template "{*actor*} translated/edited: <a href='http://bloglation.com/origs/{*orig_id*}/posts/{*post_id*}?version={*post_version*}'>{*post_title*}</a> to {*post_language*}",
			   "Read it, rate it and/or make it better. Help spread the knowledge in other cultures!"
  end

  def publish_tx(post, orig_title, facebook_session)
    send_as :user_action
    from facebook_session.user
    data :actor => facebook_session.user.first_name, :orig_id => post.orig_id, :post_id => post.id, :post_title => orig_title, :post_version => post.version, :post_language => post.language.name
  end
end
