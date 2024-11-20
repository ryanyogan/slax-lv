defmodule Slax.Chat do
  alias Slax.Chat.Room
  alias Slax.Repo

  @spec get_first_room!() :: Room.t()
  def get_first_room! do
    [room | _] = list_rooms()
    room
  end

  @spec get_room!(integer()) :: Room.t()
  def get_room!(id) do
    Repo.get!(Room, id)
  end

  @spec list_rooms() :: [Room.t()]
  def list_rooms do
    Room |> Repo.all()
  end
end
