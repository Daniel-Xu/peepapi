defmodule Peepchat.RegistrationController do
  use Peepchat.Web, :controller
  alias Peepchat.{User, Repo, UserView, ChangesetView}

  def create(conn, %{"data" => %{"type" => "users",
        "attributes" => user_params}}) do

    changeset = User.changeset(%User{}, user_params)

    case Repo.insert changeset do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render(UserView, "show.json", data: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChangesetView, "error.json", changeset: changeset)

    end

  end

end
