class DashboardController < ApplicationController
  def index
    @subscriptions = current_user.subscriptions.take(3)
  end
end
