# frozen_string_literal: true

class AuthOperationTest < ActiveSupport::TestCase
  describe "Auth::Operation::CreateAccount" do
    it "accepts valid email and passwords" do
      result = Auth::Operation::CreateAccount.wtf?({
        email: "auth@demo.test",
        password: "password",
        password_confirm: "password"
      })
      assert result.success?
    end

    it "fails on invalid email" do
      result = Auth::Operation::CreateAccount.wtf?({email: "auth@demo"})
      assert result.failure?
    end

    it "returns error message for invalid email" do
      result = Auth::Operation::CreateAccount.wtf?({
        email: "auth@demo",
        password: "password",
        password_confirm: "password"
      })
      assert result.failure?
      assert_equal "Email invalid.", result[:error]
    end

    it "validates passwords" do
      result = Auth::Operation::CreateAccount.wtf?({
        email: "auth1@demo.test",
        password: "password",
        password_confirm: "password123"
      })
      assert result.failure?
      assert_equal "Passwords do not match.", result[:error]
    end

    it "validates input, ecrypts the password, and saves user" do
      result = Auth::Operation::CreateAccount.wtf?({
        email: "auth2@demo.test",
        password: "password",
        password_confirm: "password"
      })
      assert result.success?
      user = result[:user]
      assert user.persisted?
      assert_equal "auth2@demo.test", user.email
      assert_equal 60, user.password.size
      assert_equal "created, please verify account", user.state
    end

    it "doesn't allow two users with same email" do
      result = Auth::Operation::CreateAccount.wtf?({
        email: "auth3@demo.test",
        password: "password",
        password_confirm: "password"
      })
      assert result.success?

      result = Auth::Operation::CreateAccount.wtf?({
        email: "auth3@demo.test",
        password: "password",
        password_confirm: "password"
      })
      assert result.failure?
    end
  end
end
