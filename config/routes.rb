Rails.application.routes.draw do
	get "up" => "rails/health#show", as: :rails_health_check

	root "pages#home"
	get "visit", to: "pages#visit", as: :visit
	get "about", to: "pages#about", as: :about

	resources :customers
	resources :bikes

	resources :repairs do
		delete "intake_photos/:attachment_id",
			to: "repairs#destroy_intake_photo",
			as: :intake_photo
	end

	resources :services
	resources :staff
end