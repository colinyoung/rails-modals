Rails.application.routes.draw do
  get 'posts/new', to: "posts#new", as: "new_post"
  get 'posts/wizard', to: "posts#wizard", as: "new_post_wizard"
  post 'posts', to: "posts#create", as: "posts"

  root to: "posts#index"
end
