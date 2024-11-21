defmodule SlaxWeb.Components.RoomComponents do
  use SlaxWeb, :live_component

  alias Slax.Chat.{Room, Message}
  alias Slax.Accounts.User

  attr :active, :boolean, required: true
  attr :room, Room, required: true

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

  attr :message, Message, required: true
  attr :dom_id, :string, required: true
  attr :timezone, :string, required: true

  def message(assigns) do
    ~H"""
    <div id={@dom_id} class="relative flex px-4 py-3">
      <div class="size-10 rounded flex-shrink-0 bg-slate-300"></div>
      <div class="ml-2">
        <div class="-mt-1">
          <.link class="text-sm font-semibold hover:underline">
            <span><%= username(@message.user) %></span>
          </.link>
          <span :if={@timezone} class="ml-1 text-xs text-gray-500">
            <%= message_timestamp(@message, @timezone) %>
          </span>
          <p class="text-sm"><%= @message.body %></p>
        </div>
      </div>
    </div>
    """
  end

  # TODO: Move this to a shared module
  defp username(%User{} = user) do
    user.email |> String.split("@") |> hd() |> String.capitalize()
  end

  defp message_timestamp(message, timezone) do
    message.inserted_at
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%-l:%M %p", :strftime)
  end
end
