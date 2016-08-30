defmodule Peepchat.MessageController do
  use Peepchat.Web, :controller
  import Ecto.Query

  alias Peepchat.Message
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]
  plug Guardian.Plug.EnsureAuthenticated, handler: Peepchat.AuthErrorHandler

  def index(conn, _params) do
    messages = Repo.all(Message)
    render(conn, "index.json", data: messages)
  end

  def create(conn, %{"data" => data = %{"type" => "messages", "attributes" => _message_params}}) do

    changeset =
      Guardian.Plug.current_resource(conn)
      |> build_assoc(:messages)
      |> Message.changeset(Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, message} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", message_path(conn, :show, message))
        |> render(:show, data: message)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Peepchat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    message = Repo.get!(Message, id)
    render(conn, "show.json", data: message)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "message", "attributes" => _message_params}}) do
    message = Repo.get!(Message, id)
    changeset = Message.changeset(message, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, message} ->
        render(conn, "show.json", data: message)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Peepchat.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    message = Repo.get!(Message, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(message)

    send_resp(conn, :no_content, "")
  end

end
