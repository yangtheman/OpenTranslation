ActsAsFerret::define_index('shared',
  :models => {
	      OrigPost  => {:fields => [:url, :title, :content]},
	      Post => {:fields => [:title, :content]}
  },
  :ferret => {
	      :default_fields => [:first_name, :last_name, :phone, :bio, :name, :description, :title, :body]
  }
)
