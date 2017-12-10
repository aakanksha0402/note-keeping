Rails.application.routes.draw do
  # resources :note_tags
  # resources :tags

  devise_for :users, controllers: {
       sessions: 'users/sessions',
       registrations: 'users/registrations',
       passwords: 'users/passwords'
     }

  resources :notes do
    member do
      post 'share'
      post 'add_tags'
      delete 'remove_tag/:tag_id', action: "remove_tag", as: :remove_tag
      delete 'remove_user/:user_id', action: "remove_user", as: :remove_user
    end
    get 'edit_permission/:note_user_id', action: "edit_permission", as: :edit_permission, on: :collection
    patch 'save_permission/:note_user_id', action: "save_permission", as: :save_permission, on: :collection
  end

  root 'notes#index'
end
