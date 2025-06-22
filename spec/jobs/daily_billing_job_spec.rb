# require "rails_helper"
#
# RSpec.describe DailyBillingJob, type: :job do
#   let(:user) { FactoryBot.create(:user) }
#   let(:payment_method) { FactoryBot.create(:payment_method, user:) }
#
#   describe "#perform" do
#     context "when there are subscriptions with billing_day_of_month today" do
#       let!(:subscription) do
#         FactoryBot.create(:subscription,
#           user:,
#           payment_method: payment_method,
#           billing_day_of_month: 1,
#           active: true,
#           billing_cycle: "monthly",
#           price: 1000)
#       end
#
#       it "creates a payment history" do
#         travel_to Time.zone.local(2025, 5, 1) do
#           expect { described_class.perform_now }
#             .to change(Payment, :count).by(1)
#           payment = Payment.last
#           expect(payment.subscription).to eq(subscription)
#           expect(payment.amount).to eq(1000)
#         end
#       end
#     end
#   end
# end
