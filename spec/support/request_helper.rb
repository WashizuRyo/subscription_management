module RequestHelper
  def login_as(user)
    post login_path, params: { session: { email: user.email, password: user.password } }
  end
end
