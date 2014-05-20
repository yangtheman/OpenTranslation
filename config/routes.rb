ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"
  map.login	'/login',     :controller => "sessions",  :action => "new"
  map.logout	'/logout',    :controller => "sessions",  :action => "destroy"
  map.fb_login	'/fb_login',  :controller => "sessions",  :action => "fb_login"
  map.cp_login	'/cp_login',  :controller => "sessions",  :action => "create"
  map.search	'/search',    :controller => "posts",	  :action => "search"
  map.about     '/about',     :controller => "info",	  :action => "about"
  map.tos	'/tos',	      :controller => "info",	  :action => "tos"
  map.browser	'/browser',   :controller => "info",	  :action => "browser"
  #map.exception	'/exception', :controller => "posts", :action => "exception"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.resources :origs do |orig|
    orig.resources :posts, :member => {:rate => :put}, :collection => {:add_trans => :post}
  end
  map.resources :users
  map.resources :welcome, :collection => {:allposts => :get}
  map.resource :session, :member => {:destroy => :get, :add_openid => :post, :openid_reg => :get}
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
