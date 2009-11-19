class InfoController < ApplicationController
  def about
  end

  def tos
  end

  def browser
    @browser_type = ua_identifier(request.user_agent)
  end
end
