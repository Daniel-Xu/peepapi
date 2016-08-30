defmodule Peepchat.RoomView do
  use Peepchat.Web, :view
  use JaSerializer.PhoenixView
  attributes [:name]

  has_one :owner, link: :user_link, serializer: Peepchat.UserView, include: false, identifiers: :when_included
  has_many :messages, serializer: Peepchat.MessageView

  def user_link(room, conn) do
    user_url(conn, :show, room.owner_id)
  end

end
