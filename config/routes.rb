KoeterTag::Application.routes.draw do

  get '/:token' => 'pages#show', as: 'page'
  get '/:token/pick_user' => 'pages#pick_user', as: 'pick_user'
  match '/:token/user_picked' => 'pages#user_picked', as: 'user_picked', via: [:get, :post]
  post '/pages/create', as: 'new_page'

  root 'main#index'

end
