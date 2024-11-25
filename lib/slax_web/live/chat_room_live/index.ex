defmodule SlaxWeb.ChatRoomLive.Index do
  use SlaxWeb, :live_view

  alias Slax.Chat

  @impl true
  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms_with_joined(socket.assigns.current_user)

    socket
    |> assign(page_title: "All rooms")
    |> stream_configure(:rooms, dom_id: fn {room, _} -> "room-#{room.id}" end)
    |> stream(:rooms, rooms)
    |> ok()
  end

  @impl true
  def handle_event("toggle-room-membership", %{"id" => id}, socket) do
    {room, joined?} =
      id
      |> Chat.get_room!()
      |> Chat.toggle_room_membership(socket.assigns.current_user)

    socket
    |> stream_insert(:rooms, {room, joined?})
    |> noreply()
  end
end
