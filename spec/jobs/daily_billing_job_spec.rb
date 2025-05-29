require 'rails_helper'

RSpec.describe DailyBillingJob, type: :job do
  let(:user) { FactoryBot.create(:user) }
  let(:payment_method) { FactoryBot.create(:payment_method, user: user) }
  let(:today) { Date.current }

  describe '#perform' do
    context '今日が請求日のサブスクリプションがある場合' do
      let!(:subscription) do
        FactoryBot.create(:subscription,
                          user:,
                          payment_method: payment_method,
                          billing_date: today,
                          active: true,
                          billing_cycle: 'monthly',
                          price: 1000)
      end

      it '支払履歴を作成する' do
        expect { described_class.perform_now }
          .to change(Payment, :count).by(1)
        payment = Payment.last
        expect(payment.subscription).to eq(subscription)
        expect(payment.amount).to eq(1000)
        expect(payment.status).to eq(0)
      end
    end
  end
end
