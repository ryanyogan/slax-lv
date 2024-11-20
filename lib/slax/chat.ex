defmodule Slax.Chat do
  alias Slax.Chat.{Room, Message}
  alias Slax.Repo

  import Ecto.Query

  @spec get_first_room!() :: Room.t()
  def get_first_room! do
    Repo.one!(from r in Room, limit: 1, order_by: [asc: :name])
  end

  @spec get_room!(integer()) :: Room.t()
  def get_room!(id) do
    Repo.get!(Room, id)
  end

  @spec list_rooms() :: [Room.t()]
  def list_rooms do
    Repo.all(from r in Room, order_by: [asc: :name])
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

  @spec list_messages_in_room(Room.t()) :: [Message.t()]
  def list_messages_in_room(%Room{id: room_id}) do
    Message
    |> where([m], m.room_id == ^room_id)
    |> order_by([m], asc: :inserted_at, asc: :id)
    |> preload(:user)
    |> Repo.all()
  end
end
