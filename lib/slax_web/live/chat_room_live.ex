defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  import SlaxWeb.Components.RoomComponents

  alias Slax.Repo
  alias Slax.Chat.Room

  @impl true
  def mount(_params, _session, socket) do
    rooms = Repo.all(Room)
    room = rooms |> hd()

    {:ok, assign(socket, room: room, rooms: rooms, hide_topic?: false)}
  end

  @impl true
  def handle_event("toggle-topic", _unsigned_params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end
end
