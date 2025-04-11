require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { FactoryBot.create(:user) }

  describe "user signup" do
    context "invalid information" do
      scenario "user cannot signup" do
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
    end

    context "valid information" do
      scenario "user can signup" do
        visit signup_path

        expect {
          fill_in_signup_form("tester",
                              "valid@example.com",
                              "password",
                              "password")
          click_button "アカウントを作成する"
        }.to change(User, :count).by(1)

        aggregate_failures do
          expect(page).to have_content "サインアップに成功しました！"
          expect(page).to have_http_status(:success)
          expect(page).to have_current_path "/users/#{User.find_by(email: "valid@example.com").id}"
          expect(page).to have_link("ログアウト", href: logout_path)
        end
      end
    end
  end

  describe "user login and logout" do
    context "with valid email, invalid password information" do
      scenario "user cannot login" do
        visit login_path

        fill_in_login_form(user.email, "invalid")
        click_button "ログイン"

        aggregate_failures do
          expect(page).to have_content("無効なパスワードまたはメールアドレスです")
          visit root_path
          expect(page).to_not have_content("無効なパスワードまたはメールアドレスです")
          expect(page).to have_link("ログイン", href: login_path)
        end
      end
    end

    context "with valid information" do
      scenario "user can login followed by logout" do
        visit login_path

        fill_in_login_form(user.email, user.password)
        click_button "ログイン"

        aggregate_failures do
          expect(page).to have_current_path user_path(user)
          expect(page).to_not have_link("ログイン", href: login_path)
          expect(page).to have_link("ログアウト", href: logout_path)
        end

        click_link "ログアウト"
        aggregate_failures do
          expect(page).to have_link("ログイン", href: login_path)
          expect(page).to_not have_link("ログアウト", href: logout_path)
        end
      end
    end
  end

  def fill_in_signup_form(name, email, password, password_confirmation)
    fill_in "名前", with: name
    fill_in "メールアドレス", with: email
    fill_in "パスワード", with: password
    fill_in "パスワード確認", with: password_confirmation
  end

  def fill_in_login_form(email, password)
    fill_in "メールアドレス", with: email
    fill_in "パスワード", with: password
  end
end
