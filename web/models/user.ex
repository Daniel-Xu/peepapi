defmodule Peepchat.User do
  use Peepchat.Web, :model
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :rooms, Peepchat.Room
    has_many :messages, Peepchat.Message

    timestamps
  end

  @required_fields ~w(email password password_confirmation)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:password, min: 8)
    |> validate_format(:email, ~r/@/)
    |> validate_confirmation(:password)
    |> hash_password
    |> unique_constraint(:email)
  end

  def hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->

        put_change(changeset, :password_hash, hashpwsalt(password))
      _ ->
        changeset
    end
  end

end
