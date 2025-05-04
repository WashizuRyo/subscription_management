module ApplicationHelper
  def dashboard_tab?
    controller.controller_name == "dashboard" && controller.action_name == "index"
  end

  def subscriptions_tab?
    controller.controller_name == "subscriptions" && controller.action_name == "index"
  end

  def tags_tab?
    controller.controller_name == "tags" && controller.action_name == "index"
  end

  def payment_methods_tab?
    controller.controller_name == "payment_methods" && controller.action_name == "index"
  end
end
