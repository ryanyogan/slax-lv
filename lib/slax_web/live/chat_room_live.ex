defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  import SlaxWeb.Components.RoomComponents

  alias Slax.Chat

  @impl true
  @spec mount(any(), any(), any()) :: {:ok, any()}
  def mount(_params, _session, socket) do
    rooms = Chat.list_rooms()

    {:ok, assign(socket, rooms: rooms)}
  end

  @impl true
  @spec handle_params(map(), any(), any()) :: {:noreply, any()}
  def handle_params(params, _uri, socket) do
    room =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          Chat.get_room!(id)

        :error ->
          Chat.get_first_room!()
      end

    {:noreply, assign(socket, hide_topic?: false, room: room)}
  end

  @impl true
  @spec handle_event(<<_::96>>, any(), map()) :: {:noreply, map()}
  def handle_event("toggle-topic", _unsigned_params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end
end
