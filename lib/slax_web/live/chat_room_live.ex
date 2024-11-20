defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  import SlaxWeb.Components.RoomComponents

  alias Slax.Chat

  @impl true
  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms()

    {:ok, assign(socket, rooms: rooms)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    room =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          Chat.get_room!(id)

        :error ->
          Chat.get_first_room!()
      end

    messages = Chat.list_messages_in_room(room)

    {:noreply,
     assign(socket,
       hide_topic?: false,
       room: room,
       page_title: "#" <> room.name,
       messages: messages
     )}
  end

  @impl true
  def handle_event("toggle-topic", _unsigned_params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end
end
