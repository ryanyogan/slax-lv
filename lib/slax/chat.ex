defmodule Slax.Chat do
  alias Slax.Accounts.User
  alias Slax.Chat.{Room, Message, RoomMembership}
  alias Slax.Repo

  import Ecto.Query

  @pubsub Slax.PubSub

  ### Publiish-Subscribe ###

  def subscribe_to_room(room) do
    Phoenix.PubSub.subscribe(@pubsub, topic(room.id))
  end

  def unsubscribe_from_room(room) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(room.id))
  end

  defp topic(room_id), do: "chat_room:#{room_id}"

  ### Rooms ###

  @spec get_first_room!() :: Room.t()
  def get_first_room! do
    Repo.one!(from r in Room, limit: 1, order_by: [asc: :name])
  end

  @spec get_room!(integer()) :: Room.t()
  def get_room!(id) do
    Repo.get!(Room, id)
  end

  def joined?(%Room{} = room, %User{} = user) do
    Repo.exists?(
      from rm in RoomMembership,
        where:
          rm.room_id ==
            ^room.id and rm.user_id == ^user.id
    )
  end

  def toggle_room_membership(room, user) do
    case Repo.get_by(RoomMembership, room_id: room.id, user_id: user.id) do
      %RoomMembership{} = membership ->
        Repo.delete(membership)
        {room, false}

      nil ->
        join_room!(room, user)
        {room, true}
    end
  end

  @spec list_rooms() :: [Room.t()]
  def list_rooms do
    Repo.all(from r in Room, order_by: [asc: :name])
  end

  def list_joined_rooms(%User{} = user) do
    user
    |> Repo.preload(:rooms)
    |> Map.fetch!(:rooms)
    |> Enum.sort_by(& &1.name)
  end

  def list_rooms_with_joined(%User{} = user) do
    query =
      from r in Room,
        left_join: m in RoomMembership,
        on: r.id == m.room_id and m.user_id == ^user.id,
        select: {r, not is_nil(m.id)},
        order_by: [asc: :name]

    Repo.all(query)
  end

  @spec change_room(Room.t(), map()) :: Ecto.Changeset.t()
  def change_room(room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  @spec create_room(map()) :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  def create_room(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_room(Room.t(), map()) :: {:ok, Room.t()} | {:error, Ecto.Changeset.t()}
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @spec join_room!(Room.t(), User.t()) :: :ok
  def join_room!(room, user) do
    Repo.insert!(%RoomMembership{room: room, user: user})
  end

  ### Messages ###

  @spec change_message(Message.t(), map()) :: Ecto.Changeset.t()
  def change_message(message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def create_message(room, attrs, user) do
    with {:ok, message} <-
           %Message{room: room, user: user}
           |> Message.changeset(attrs)
           |> Repo.insert() do
      Phoenix.PubSub.broadcast!(@pubsub, topic(room.id), {:new_message, message})

      {:ok, message}
    end
  end

  @spec delete_message_by_id(integer(), User.t()) :: :ok
  def delete_message_by_id(id, %User{id: user_id}) do
    message = %Message{user_id: ^user_id} = Repo.get(Message, id)

    Repo.delete(message)
    Phoenix.PubSub.broadcast!(@pubsub, topic(message.room_id), {:message_deleted, message})
  end

  @spec list_messages_in_room(Room.t()) :: [Message.t()]
  def list_messages_in_room(%Room{id: room_id}) do
    Message
    |> where([m], m.room_id == ^room_id)
    |> order_by([m], asc: :inserted_at, asc: :id)
    |> preload(:user)
    |> Repo.all()
  end
end
