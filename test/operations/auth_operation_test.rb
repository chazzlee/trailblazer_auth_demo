# frozen_string_literal: true

class NotRandom
  def self.urlsafe_base64(*)
    "this is not random"
  end
end

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

    it "creates account and verify-account key" do
      result = Auth::Operation::CreateAccount.wtf?({
        email: "auth4@demo.test",
        password: "password",
        password_confirm: "password"
      })
      user = result[:user]
      assert user.persisted?
      assert result.success?

      verify_account_token = VerifyAccountKey.find_by(user_id: user.id).key
      assert_equal 43, verify_account_token.size
    end

    it "fails when inserting the same {verify_account_key} twice" do
      options = {
        email: "test@test.com",
        password: "1234",
        password_confirm: "1234",
        secure_random: NotRandom
      }
      result = Auth::Operation::CreateAccount.wtf?(options)
      assert result.success?
      assert_equal "this is not random", result[:verify_account_key]

      result = Auth::Operation::CreateAccount.wtf?(options.merge({email: "test2@test.com"}))
      assert result.failure?
      assert_equal "Please try again.", result[:error]
    end

    it "creates account and sends a welcome email" do
      options = {
        email: "test3@test.com",
        password: "1234",
        password_confirm: "1234",
        secure_random: NotRandom
      }
      result = nil
      assert_email 1 do
        result = Auth::Operation::CreateAccount.wtf?(options)
      end
      assert result.success?
      assert_match(/\/auth\/verify_account\/#{user.id}_#{verify_account_key.key}/, result[:email].body.to_s)
    end
  end
end
