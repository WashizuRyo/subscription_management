class DashboardController < ApplicationController
  before_action :logged_in_user

  def index
    # @this_month_total_billing = Subscription.this_month_total_billing(current_user)
    @latest_subscriptions = Subscription.latest(current_user)
    # @next_billing_soon_subscriptions = Subscription.next_billing_soon(current_user)
  end
end
