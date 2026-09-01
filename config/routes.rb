Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "services", to: "pages#services", as: :services
  get "visit", to: "pages#visit", as: :visit
  get "about", to: "pages#about", as: :about
end