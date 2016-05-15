defmodule Peepchat.RoomView do
  use Peepchat.Web, :view
  attributes [:name]

  has_one :owner, link: :user_link

  def user_link(room, conn) do
    user_url(conn, :show, room.owner_id)
  end

end
