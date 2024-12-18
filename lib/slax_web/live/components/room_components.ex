defmodule SlaxWeb.Components.RoomComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: SlaxWeb.Endpoint,
    router: SlaxWeb.Router,
    statics: SlaxWeb.static_paths()

  import SlaxWeb.CoreComponents

  alias Slax.Chat.{Room, Message}
  alias Slax.Accounts.User
  alias Phoenix.LiveView.JS

  attr :active, :boolean, required: true
  attr :room, Room, required: true
  attr :unread_count, :integer, required: true

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
      <.unread_message_counter count={@unread_count} />
    </.link>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :target, :any, default: nil

  def room_form(assigns) do
    ~H"""
    <.simple_form
      for={@form}
      id="room-form"
      phx-change="validate-room"
      phx-submit="save-room"
      phx-target={@target}
    >
      <.input field={@form[:name]} type="text" label="Name" phx-debounce />
      <.input field={@form[:topic]} type="text" label="Topic" phx-debounce />

      <:actions>
        <.button phx-disable-with="Saving..." class="w-full">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  attr :message, Message, required: true
  attr :dom_id, :string, required: true
  attr :timezone, :string, required: true
  attr :current_user, User, required: true

  def message(assigns) do
    ~H"""
    <div id={@dom_id} class="group relative flex px-4 py-3">
      <button
        :if={@current_user.id == @message.user_id}
        data-confirm="Are you sure?"
        phx-click="delete-message"
        phx-value-id={@message.id}
        class="absolute top-4 right-4 group-hover:block hidden text-red-500 hover:text-red-800 cursor-pointer"
      >
        <.icon name="hero-trash" class="size-4" />
      </button>
      <img
        class="size-10 rounded cursor-pointer"
        phx-click="show-profile"
        phx-value-user-id={@message.user.id}
        src={~p"/images/one_ring.jpg"}
      />
      <div class="ml-2">
        <div class="-mt-1">
          <.link
            phx-click="show-profile"
            phx-value-user-id={@message.user.id}
            class="text-sm font-semibold hover:underline"
          >
            <span><%= @message.user.username %></span>
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

  attr :count, :integer, required: true

  defp unread_message_counter(assigns) do
    ~H"""
    <span
      :if={@count > 0}
      class="flex items-center justify-center bg-blue-500 rounded-full font-medium h-5 px-2 ml-auto text-xs text-white"
    >
      <%= @count %>
    </span>
    """
  end

  def format_date(%Date{} = date) do
    today = Date.utc_today()

    case Date.diff(today, date) do
      0 ->
        "Today"

      1 ->
        "Yesterday"

      _ ->
        format_str = "%A, %B %e#{ordinal(date.day)}#{if today.year != date.year, do: " %Y"}"
        Timex.format!(date, format_str, :strftime)
    end
  end

  defp ordinal(day) do
    cond do
      rem(day, 10) == 1 and day != 11 -> "st"
      rem(day, 10) == 2 and day != 12 -> "nd"
      rem(day, 10) == 3 and day != 13 -> "rd"
      true -> "th"
    end
  end

  attr :user, User, required: true
  attr :online, :boolean, default: false

  def user(assigns) do
    ~H"""
    <.link class="flex items-center h-8 hover:bg-gray-300 text-sm pl-8 pr-3" href="#">
      <div class="flex justify-center w-4">
        <%= if @online do %>
          <span class="size-2 rounded-full bg-blue-500"></span>
        <% else %>
          <span class="size-2 rounded-full border-gray-500 border-2"></span>
        <% end %>
      </div>
      <span class="ml-2 leading-none"><%= @user.username %></span>
    </.link>
    """
  end

  attr :dom_id, :string, required: true
  attr :text, :string, required: true
  attr :on_click, JS, required: true

  def toggler(assigns) do
    ~H"""
    <button id={@dom_id} phx-click={@on_click} class="flex items-center flex-grow focus:outline-none">
      <.icon name="hero-chevron-down" id={@dom_id <> "-chevron-down"} class="size-4" />
      <.icon
        id={@dom_id <> "-chevron-right"}
        name="hero-chevron-right"
        class="size-4"
        style="display: none;"
      />

      <span class="ml-2 leading-none font-medium text-sm">
        <%= @text %>
      </span>
    </button>
    """
  end

  defp message_timestamp(message, timezone) do
    message.inserted_at
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%-l:%M %p", :strftime)
  end

  def toggle_rooms() do
    JS.toggle(to: "#rooms-toggler-chevron-down")
    |> JS.toggle(to: "#rooms-toggler-chevron-right")
    |> JS.toggle(to: "#rooms-list")
  end

  def toggle_users() do
    JS.toggle(to: "#users-toggler-chevron-down")
    |> JS.toggle(to: "#users-toggler-chevron-right")
    |> JS.toggle(to: "#users-list")
  end
end
