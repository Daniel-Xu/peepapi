defmodule Peepchat.MessageView do
  use Peepchat.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body, :inserted_at, :updated_at]
  
  has_one :user,
    field: :user_id,
    type: "user"
  has_one :room,
    field: :room_id,
    type: "room"

end
