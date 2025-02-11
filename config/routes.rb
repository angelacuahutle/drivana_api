Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  
  root "bookings#index"
  
  resources :bookings, only: [:create, :show, :index] do
    member do
      get  :extend_form          # Ruta GET para mostrar el formulario de extensión
      post :extend               # Ruta POST para procesar el formulario y crear la extensión
      get  :tickets
      get  :consolidated_ticket
    end
  end
  
  resources :tickets, only: [:index, :create, :show]
end