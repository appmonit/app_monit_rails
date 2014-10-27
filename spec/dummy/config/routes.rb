Dummy::Application.routes.draw do
  resources :posts do
    get :with_exception, on: :collection
  end
end
