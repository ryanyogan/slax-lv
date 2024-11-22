defmodule SlaxWeb.ChatRoomLive.Index do
  use SlaxWeb, :live_view

  alias Slax.Chat

  @impl true
  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms_with_joined(socket.assigns.current_user)

    socket =
      socket
      |> assign(page_title: "All rooms")
      |> stream_configure(:rooms, dom_id: fn {room, _} -> "room-#{room.id}" end)
      |> stream(:rooms, rooms)

    {:ok, socket}
  end
end
