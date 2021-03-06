require "sidekiq/web"

Rails.application.routes.draw do
  
  constraints host: "tbnow.co" do
    get "/:token", to: "bitlies#bitly"
  end
  
  devise_scope :user do
    devise_for :users,
      controllers: {
        omniauth_callbacks: "omniauth_callbacks",
        registrations: "registrations",
        sessions: "sessions"
      }
    
    post "/twilio/voice"
    post "/twilio/sms"
    get "/users/auth/facebook/setup", to: "omniauth_callbacks#setup"
    get "/track/img/:args" => "events#track", as: :track_img
    get "/track/redirect/:args" => "events#track", as: :track_redirect
    post "/track/members/save" => "events#members_save", as: :members_save
    post "/track/events/save" => "events#events_save", as: :events_save
    
    authenticated :user, lambda { |u| u.admin? } do
      resources :organizations, only: [:index, :edit, :update]
      mount Sidekiq::Web => "/sidekiq"
    end
    
    scope "/:permalink" do
      get "/examples/:example" => "organizations#example", as: :example
      get "/unsubscribe/:member_token" => "members#unsubscribe", as: :unsubscribe
      get "/open/:message_token/:member_token" => "messages#open", as: :open, defaults: { format: :gif }
      get "/click/:message_token/:member_token/:ordinal" => "messages#click", as: :click
      get "/accept/:token" => "folderships#accept", as: :foldership_invitation
      get "/sign-up" => "devise/registrations#new", as: :signup
    end
    
    authenticated :user do
      resources :organizations, only: [:new, :create]
      
      scope "/:permalink" do
        get "/permissions" => "modules#permissions", as: :permissions
        post "/track" => "rooms#presence", as: :track
        get "/my-account" => "devise/registrations#edit"
        post "/tasks/sort" => "tasks#sort", as: :sort_tasks
        post "/members/import" => "members#import", as: :import
      
        resources :members
        resources :segments
        resources :events
        resources :tasks
        resources :folderships, only: :index
        resources :messages
        resources :fields
        resources :identities
        
        match "/sequences/bulk/add" => "sequences#bulk_add", as: :sequence_bulk_add, via: [:get, :post]
        match "/sequences/bulk/remove" => "sequences#bulk_add", as: :sequence_bulk_remove, via: [:get, :post]
        
        resources :sequences

        resources :rooms, path: :attendance do
          resources :meetings
        end
      
        resources :folders do
          post "/tasks/sort" => "folder_tasks#sort", as: :sort_tasks
          delete "/reset" => "folders#reset", as: :reset
          resources :tasks, controller: "folder_tasks"
          resources :homes
          resources :comments

          resources :folderships, path: :members do
            post "/accept" => "folderships#accept", as: :accept
          end
        
          resources :documents do
            get "/download" => "documents#download", as: :download
          end
        end
      end
    end
    
    get "/:permalink" => "devise/sessions#new", as: :signin
  end
  
  root to: "modules#redirect"
end
