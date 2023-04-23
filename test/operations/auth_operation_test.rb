# frozen_string_literal: true

class AuthOperationTest < Minitest::Spec
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
        email: "auth@demo.test",
        password: "password",
        password_confirm: "password123"
      })
      assert result.failure?
      assert_equal "Passwords do not match.", result[:error]
    end
  end
end
