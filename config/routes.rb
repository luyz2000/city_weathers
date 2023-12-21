Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :weather, only: :show, param: :city_name do
    member do
      get :recomended_city
    end
  end

end
