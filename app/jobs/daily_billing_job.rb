class DailyBillingJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Daily billing job started at #{Time.current}"

    # 今日が請求日のサブスクリプションを取得
    subscriptions_to_bill = Subscription.joins(:user)
                                      .where(billing_day_of_month: Date.current)
                                      .where(active: true)
                                      .includes(:payment_method, :user)

    Rails.logger.info "Found #{subscriptions_to_bill.count} subscriptions to bill"

    subscriptions_to_bill.find_each do |subscription|
      begin
        create_payment_record(subscription)
        update_next_billing_day_of_month(subscription)
        Rails.logger.info "Successfully processed subscription ID: #{subscription.id}"
      rescue => e
        Rails.logger.error "Failed to process subscription ID: #{subscription.id}, Error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end

    Rails.logger.info "Daily billing job completed at #{Time.current}"
  end

  private

  def create_payment_record(subscription)
    Payment.create!(
      subscription: subscription,
      payment_method: subscription.payment_method,
      amount: subscription.price,
      plan: subscription.plan,
      billing_date: subscription.billing_day_of_month,
    )
  end

  def update_next_billing_day_of_month(subscription)
    next_date = case subscription.billing_cycle
    when "monthly"
                  subscription.billing_day_of_month + 1.month
    when "yearly"
                  subscription.billing_day_of_month + 1.year
    when "weekly"
                  subscription.billing_day_of_month + 1.week
    else
                  subscription.billing_day_of_month + 1.month # デフォルトは月次
    end

    subscription.update!(billing_day_of_month: next_date)
  end
end
