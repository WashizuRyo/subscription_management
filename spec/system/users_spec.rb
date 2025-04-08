require 'rails_helper'

RSpec.describe "Users", type: :system do
  scenario "user cannot signup with invalid information" do
    visit signup_path
    expect {
      fill_in_signup_form(" ", "user@invalid", "foo", "bar")
      click_button "アカウントを作成する"

      aggregate_failures do
        expect(page).to have_content "エラーが発生しました。(4個)"
        expect(page).to have_content "名前を入力してください"
        expect(page).to have_content "有効なメールアドレスを入力してください"
        expect(page).to have_content "パスワードは6文字以上で入力してください"
        expect(page).to have_content "パスワード確認が一致しません"
        expect(page).to have_http_status(:unprocessable_entity)
      end
    }.to_not change(User, :count)
  end

  def fill_in_signup_form(name, email, password, password_confirmation)
    fill_in "名前", with: name
    fill_in "メールアドレス", with: email
    fill_in "パスワード", with: password
    fill_in "パスワード確認", with: password_confirmation
  end
end
