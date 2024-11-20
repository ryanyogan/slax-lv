defmodule SlaxWeb.ChatRoomLive.Edit do
  use SlaxWeb, :live_view

  alias Slax.Chat

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    room = Chat.get_room!(id)
    changeset = Chat.change_room(room)

    socket =
      socket
      |> assign(page_title: "Edit chat room", room: room)
      |> assign_form(changeset)

    {:ok, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
