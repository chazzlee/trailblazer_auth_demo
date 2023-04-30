# frozen_string_literal: true

class AuthMailer < ApplicationMailer
  default from: "notifications@example.com"

  def welcome_email
    @email = params[:email]
    @verify_token = params[:verify_token]
    @url = "https://example.com/login"
    mail(to: @email, subject: "Welcome to my awesome site")
  end
end
