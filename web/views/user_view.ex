defmodule Peepchat.UserView do
  use Peepchat.Web, :view
  use JaSerializer.PhoenixView

  has_many :rooms, link: :rooms_link
  attributes [:email]

  def rooms_link(user, conn) do
    user_rooms_url(conn, :index, user.id)
  end
end
