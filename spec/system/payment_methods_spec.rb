require 'rails_helper'

RSpec.describe "PaymentMethods", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let!(:payment_method) { FactoryBot.create(:payment_method, user: user) }

  describe "create new payment_method" do
    it "displays 支払い方法の登録に成功しました when payment_method is created" do
      login_as user
      visit user_payment_methods_path(user)

      expect {
        fill_in "new_payment_method_provider", with: "test_provider"
        fill_in "new_payment_method_method_type", with: "test_method_type"
        fill_in "new_payment_method_memo", with: "test_memo"

        click_button "支払い方法を追加"
      }.to change(PaymentMethod, :count).by(1)

      expect(page).to have_content "支払い方法の登録に成功しました"
      expect(page).to have_content "test_provider"
      expect(page).to have_content "test_method_type"
      expect(page).to have_content "test_memo"
    end

    it "displays validation errors when payment_method is invalid" do
      login_as user
      visit user_payment_methods_path(user)

      expect {
        click_button "支払い方法を追加"
      }.to_not change(PaymentMethod, :count)

      expect(page).to have_content '提供元を入力してください'
      expect(page).to have_content '種類を入力してください'
    end
  end

  # TODO: 更新機能のテストを追加(ログインができない)
  # describe "update payment_method", js: true do
  #   it "displays 支払い方法の更新に成功しました when payment_method is updated" do
  #     login_as user

  #     id = payment_method.id
  #     find("#edit_button_#{id}").click
  #     fill_in "edit_provider_#{id}", with: "update_provider"
  #     fill_in "edit_type_#{id}", with: "update_type"
  #     fill_in "edit_memo_#{id}", with: "update_memo"

  #     click_button "更新"

  #     expect(page).to have_content "支払い方法の更新に成功しました"
  #     expect(page).to have_content "update_provider"
  #     expect(page).to have_content "update_type"
  #     expect(page).to have_content "update_memo"
  #   end
  # end

  describe "delete payment_method" do
    it "displays 支払い方法の削除に成功しました when payment_method is deleted" do
      login_as user
      visit user_payment_methods_path(user)

      find("#delete_button_#{payment_method.id}").click

      expect(page).to have_content "支払い方法の削除に成功しました"
      expect(page).to_not have_content payment_method.provider
    end
  end
end
