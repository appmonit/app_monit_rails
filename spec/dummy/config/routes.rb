Dummy::Application.routes.draw do
  resources :posts do
    collection do
      get :with_exception
      get :skipped
    end
  end
end
