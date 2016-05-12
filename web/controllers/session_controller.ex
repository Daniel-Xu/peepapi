defmodule Peepchat.SessionController do
  use Peepchat.Web, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias Peepchat.{Repo, User}

  # we don't use json-api here
  def create(conn, %{"grant_type" => "password",
    "username" => email,
    "password" => password}) do
    ## handle user login

    user = Repo.get_by(User, email: email)

    cond do
      user && checkpw(password, user.password_hash) ->
        # found
        {:ok, access_token, _full_claims} = user |> Guardian.encode_and_sign(:token)
        conn
        |> json(%{access_token: access_token})

      user ->
        # 401 unauthorized
        conn
        |> put_status(401)
        |> render(Peepchat.ErrorView, "401.json")

      true ->
        # user not found
        dummy_checkpw()
        conn
        |> put_status(400)
        |> render(Peepchat.ErrorView, "400.json")
    end
  end

  def create(conn, %{"grant_type" => _}) do
    throw "Unsupported grant type"
  end

end
