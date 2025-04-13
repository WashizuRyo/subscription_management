module SystemHelper
  def fill_in_login_form(email, password)
    fill_in "メールアドレス", with: email
    fill_in "パスワード", with: password
  end

  def login_as(user)
    visit login_path
    fill_in_login_form(user.email, user.password)
    click_button "ログイン"
  end
end
