defmodule Peepchat.Message do
  use Peepchat.Web, :model

  schema "messages" do
    field :body, :string
    belongs_to :user, Peepchat.User
    belongs_to :room, Peepchat.Room

    timestamps
  end

  @required_fields ~w(body room_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
