Rails.application.routes.draw do
  get 'messages/new'
  resources :channels do
    resources :messages
  end
end
