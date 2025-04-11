class ApplicationController < ActionController::Base
  include SessionsHelper
  def hello
    render "layouts/application"
  end
end
