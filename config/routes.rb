Rails.application.routes.draw do
  # resources :note_tags
  # resources :tags

  devise_for :users, controllers: {
       sessions: 'users/sessions',
       registrations: 'users/registrations'
     }

  resources :notes do
    member do
      post 'share'
      post 'add_tags'
      delete 'remove_tag/:tag_id', action: "remove_tag", as: :remove_tag
      delete 'remove_user/:user_id', action: "remove_user", as: :remove_user
    end
  end

  root 'notes#index'
end
