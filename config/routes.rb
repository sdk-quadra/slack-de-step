# frozen_string_literal: true

Rails.application.routes.draw do
  # get "workspaces/index"
  get "sessions/create"
  get "sessions/destroy"
  get "homes/index"
  root "homes#index"

  get "auth/:provider/callback" => "sessions#create"
  get "auth/signout" => "sessions#destroy"

  resources :workspaces do
    resources :channels do
      resources :messages
    end
  end

  get "server" => "homes#server"
  post "server" => "homes#server"
end
