defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  import SlaxWeb.Components.RoomComponents

  alias Slax.Accounts
  alias Slax.Chat
  alias Slax.Chat.{Message, Room}
  alias SlaxWeb.OnlineUsers

  @impl true
  def mount(_params, _session, socket) do
    rooms = Chat.list_joined_rooms_with_unread_counts(socket.assigns.current_user)
    users = Accounts.list_users()

    timezone = get_connect_params(socket)["timezone"]

    if connected?(socket) do
      OnlineUsers.track(self(), socket.assigns.current_user)
    end

    OnlineUsers.subscribe()

    Enum.each(rooms, fn {chat, _} -> Chat.subscribe_to_room(chat) end)

    socket =
      socket
      |> assign(rooms: rooms, timezone: timezone, users: users)
      |> assign(online_users: OnlineUsers.list())
      |> assign_room_form(Chat.change_room(%Room{}))
      |> stream_configure(:messages,
        dom_id: fn
          %Message{id: id} -> "messages-#{id}"
          :unread_marker -> "messages-unread-marker"
        end
      )
      |> IO.inspect()

    {:ok, socket}
  end

  defp assign_room_form(socket, changeset) do
    assign(socket, :new_room_form, to_form(changeset))
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

    last_read_id = Chat.get_last_read_id(room, socket.assigns.current_user)

    messages =
      room
      |> Chat.list_messages_in_room()
      |> maybe_insert_unread_marker(last_read_id)

    Chat.update_last_read_id(room, socket.assigns.current_user)

    {:noreply,
     socket
     |> assign(
       hide_topic?: false,
       joined?: Chat.joined?(room, socket.assigns.current_user),
       room: room,
       page_title: "#" <> room.name
     )
     |> stream(:messages, messages, reset: true)
     |> assign_message_form(Chat.change_message(%Message{}))
     |> push_event("scroll_messages_to_bottom", %{})
     |> update(:rooms, fn rooms ->
       room_id = room.id

       Enum.map(rooms, fn
         {%Room{id: ^room_id} = room, _} ->
           {room, 0}

         other ->
           other
       end)
     end)}
  end

  defp maybe_insert_unread_marker(messages, nil), do: messages

  defp maybe_insert_unread_marker(messages, last_read_id) do
    {read, unread} = Enum.split_while(messages, &(&1.id <= last_read_id))

    if unread == [] do
      read
    else
      read ++ [:unread_marker | unread]
    end
  end

  @impl true
  def handle_event("toggle-topic", _unsigned_params, socket) do
    {:noreply, update(socket, :hide_topic?, &(!&1))}
  end

  @impl true
  def handle_event("validate-message", %{"message" => message_params}, socket) do
    changeset = Chat.change_message(%Message{}, message_params)

    {:noreply, assign_message_form(socket, changeset)}
  end

  @impl true
  def handle_event("validate-room", %{"room" => room_params}, socket) do
    changeset =
      socket.assigns.room
      |> Chat.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_room_form(socket, changeset)}
  end

  @impl true
  def handle_event("submit-message", %{"message" => message_params}, socket) do
    %{current_user: current_user, room: room} = socket.assigns

    socket =
      if Chat.joined?(room, current_user) do
        case Chat.create_message(room, message_params, current_user) do
          {:ok, _message} ->
            assign_message_form(socket, Chat.change_message(%Message{}))

          {:error, changeset} ->
            assign_message_form(socket, changeset)
        end
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("save-room", %{"room" => room_params}, socket) do
    case Chat.create_room(room_params) do
      {:ok, room} ->
        Chat.join_room!(room, socket.assigns.current_user)

        {:noreply,
         socket
         |> put_flash(:info, "Created room")
         |> push_navigate(to: ~p"/rooms/#{room}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_room_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("delete-message", %{"id" => id}, socket) do
    Chat.delete_message_by_id(id, socket.assigns.current_user)
    {:noreply, socket}
  end

  @impl true
  def handle_event("join-room", _unsigned_params, socket) do
    current_user = socket.assigns.current_user
    Chat.join_room!(socket.assigns.room, current_user)
    Chat.subscribe_to_room(socket.assigns.room)

    socket =
      assign(
        socket,
        joined?: true,
        rooms: Chat.list_joined_rooms_with_unread_counts(current_user)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    room = socket.assigns.room

    socket =
      cond do
        message.room_id == room.id ->
          Chat.update_last_read_id(room, socket.assigns.current_user)

          socket
          |> stream_insert(:messages, message)
          |> push_event("scroll_messages_to_bottom", %{})

        message.user_id != socket.assigns.current_user.id ->
          update(socket, :rooms, fn rooms ->
            Enum.map(rooms, fn
              {%Room{id: id} = room, count} when id == message.room_id ->
                {room, count + 1}

              other ->
                other
            end)
          end)

        true ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:message_deleted, message}, socket) do
    {:noreply, stream_delete(socket, :messages, message)}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    online_users = OnlineUsers.update(socket.assigns.online_users, diff)

    {:noreply, assign(socket, online_users: online_users)}
  end

  defp assign_message_form(socket, changeset) do
    assign(socket, :new_message_form, to_form(changeset))
  end
end
