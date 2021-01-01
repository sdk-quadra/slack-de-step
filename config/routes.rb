# frozen_string_literal: true

Rails.application.routes.draw do
  root "homes#index"

  get "sessions/destroy"

  get "auth/:provider/callback" => "sessions#create"

  resources :workspaces, only: [] do
    resources :channels, only: :show do
      resources :messages, only: [:new, :create, :edit, :update, :destroy]
    end
  end

  get "server" => "homes#server"
  post "server" => "homes#server"

  # sidekiq管理画面
  require "sidekiq/web"
  mount Sidekiq::Web, at: "/sidekiq"
end
