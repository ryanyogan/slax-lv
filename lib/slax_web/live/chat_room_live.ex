defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  import SlaxWeb.Components.RoomComponents

  alias Slax.Repo
  alias Slax.Chat.Room

  @impl true
  @spec mount(any(), any(), any()) :: {:ok, any()}
  def mount(_params, _session, socket) do
    rooms = Repo.all(Room)

    {:ok, assign(socket, rooms: rooms)}
  end

  @impl true
  @spec handle_params(map(), any(), any()) :: {:noreply, any()}
  def handle_params(params, _uri, socket) do
    room =
      case Map.fetch(params, "id") do
        {:ok, id} ->
          Repo.get(Room, id)

        :error ->
          List.first(socket.assigns.rooms)
      end

    {:noreply, assign(socket, hide_topic?: false, room: room)}
  end

  @impl true
  @spec handle_event(<<_::96>>, any(), map()) :: {:noreply, map()}
  def handle_event("toggle-topic", _unsigned_params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end
end
