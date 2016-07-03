Rails.application.routes.draw do
  root 'posts#new'
  resources :posts, only: [:create, :show]
end
