Rails.application.routes.draw do
  devise_for :users

  root "bookings#index"

  resources :bookings, only: [:create, :show, :index] do
    member do
      post :extend                  # POST /bookings/:id/extend
      get  :tickets                 # GET /bookings/:id/tickets
      get  :consolidated_ticket     # GET /bookings/:id/consolidated_ticket
    end
  end

  resources :tickets, only: [:create, :show]
end
