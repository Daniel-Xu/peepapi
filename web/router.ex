defmodule Peepchat.Router do
  use Peepchat.Web, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  pipeline :api_auth do
    plug :accepts, ["json", "json-api"]
    # for request, we need to verify token
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/api", Peepchat do
    pipe_through :api
    post "register", RegistrationController, :create
    post "token", SessionController, :create, as: :login
  end
  scope "/api", Peepchat do
    pipe_through :api_auth
    get "/user/current", UserController, :current, as: :current_user
    resources "user", UserController, only: [:index, :show] do
      get "rooms", RoomController, :index, as: :rooms
    end
    resources "rooms", RoomController, except: [:new, :edit]
  end

end
