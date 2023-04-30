Rails.application.routes.draw do
  get "/auth/verify_account/:token", to: "auth#verify_account", as: :verify_account
end
