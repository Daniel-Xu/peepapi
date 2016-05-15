defmodule Peepchat.RoomController do
  use Peepchat.Web, :controller
  import Ecto.Query
  plug Guardian.Plug.EnsureAuthenticated, handler: Peepchat.AuthErrorHandler

  alias Peepchat.Room

  plug :scrub_params, "room" when action in [:create, :update]

  def action(conn, _) do
    current_user = Guardian.Plug.current_resource(conn)
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, current_user])
  end

  def index(conn, %{"user_id" => user_id}, _current_user) do
    rooms = Room
    |> where(owner_id: ^user_id)
    |> Repo.all

    render(conn, "index.json", data: rooms)
  end

  def index(conn, _params, _) do
    rooms = Repo.all(Room)
    render(conn, "index.json", data: rooms)
  end

  def create(conn, %{"data" =>
      %{"type" => "rooms", "attributes" => room_attributes, "relationships" => _}},
      current_user) do
    changeset =
      current_user
      |> build_assoc(:rooms)
      |> Room.changeset(room_attributes)

    case Repo.insert(changeset) do
      {:ok, room} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", room_path(conn, :show, room))
        |> render("show.json", data: room)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Peepchat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _current_user) do
    room = Repo.get!(Room, id)
    render(conn, "show.json", data: room)
  end

  def update(conn, %{"id" => id, "data" => %{"type" => "rooms", "attributes" => room_params}}, current_user) do

    room = Repo.get!(user_rooms(current_user), id)
    changeset = Room.changeset(room, room_params)

    case Repo.update(changeset) do
      {:ok, room} ->
        render(conn, "show.json", data: room)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Peepchat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do

    room = Repo.get!(user_rooms(current_user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(room)

    send_resp(conn, :no_content, "")
  end

  defp user_rooms(user) do
    assoc(user, :rooms)
  end
end
