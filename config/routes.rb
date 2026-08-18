Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "acoustic_snapshots#index"
  resources :acoustic_snapshots, only: [ :index, :show ]

  namespace :api do
    namespace :v1 do
      post "diagnostics/upload_audio", to: "diagnostics#upload_audio", as: :diagnostics_upload_audio
    end
  end
end
