defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  alias Slax.Repo
  alias Slax.Chat.Room

  @impl true
  def mount(_params, _session, socket) do
    room =
      Room
      |> Repo.all()
      |> hd()

    {:ok, assign(socket, room: room, hide_topic?: false)}
  end

  @impl true
  def handle_event("toggle-topic", _unsigned_params, socket) do
    {:noreply, assign(socket, hide_topic?: !socket.assigns.hide_topic?)}
  end
end
