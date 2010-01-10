require 'test_helper'

class InfoControllerTest < ActionController::TestCase

  context "on GET to :about" do
    setup do
      get :about
    end

    should_respond_with :success
    should_render_template :about
  end

  context "on GET to :tos" do
    setup do
      get :tos
    end

    should_respond_with :success
    should_render_template :tos
  end

  context "on GET to :browser" do
    setup do
      get :browser
    end

    should_respond_with :success
    should_render_template :browser
  end

end
