defmodule SlaxWeb.Components.RoomComponents do
  use SlaxWeb, :live_component

  alias Slax.Chat.Room

  attr :active, :boolean, required: true
  attr :room, Room, required: true

  @spec room_link(map()) :: Phoenix.LiveView.Rendered.t()
  def room_link(assigns) do
    ~H"""
    <.link
      class={[
        "flex items-center h-8 text-sm pl-8 pr-3",
        (@active && "bg-slate-300") || "hover:bg-slate-300"
      ]}
      patch={~p"/rooms/#{@room}"}
    >
      <.icon name="hero-hashtag" class="size-4" />
      <span class={["ml-2 leading-none", @active && "font-bold"]}>
        <%= @room.name %>
      </span>
    </.link>
    """
  end
end
