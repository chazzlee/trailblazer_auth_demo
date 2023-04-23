module Auth::Operation
  class CreateAccount < Trailblazer::Operation
    step :check_email
    fail :email_invalid_msg, fail_fast: true
    step :passwords_identical?
    fail :passwords_invalid_msg, fail_fast: true

    def check_email(ctx, email:, **)
      email =~ /\A[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+\z/ # login_email_regexp, stolen from Rodauth.
    end

    def passwords_identical?(ctx, password:, password_confirm:, **)
      password == password_confirm
    end

    def email_invalid_msg(ctx, **)
      ctx[:error] = "Email invalid."
    end

    def passwords_invalid_msg(ctx, **)
      ctx[:error] = "Passwords do not match."
    end
  end
end
