defmodule SlaxWeb.OnlineUsers do
  alias SlaxWeb.Presence

  @topic "online_users"

  @doc """
  List the number of users online.

  ## Examples

      iex> list()
      %{1 => 2, 2 => 1}
  """
  def list() do
    @topic
    |> Presence.list()
    |> Enum.into(
      %{},
      fn {id, %{metas: metas}} ->
        {String.to_integer(id), length(metas)}
      end
    )
  end

  @doc """
  Track a user as online.

  ## Examples

      iex> track(pid, user)
      :ok
  """
  def track(pid, user) do
    {:ok, _} = Presence.track(pid, @topic, user.id, %{})
    :ok
  end

  @doc """
  Determine if a user is online.

  ## Examples

      iex> online?(%{1 => 2, 2 => 1}, 1)
      true

      iex> online?(%{1 => 2, 2 => 1}, 3)
      false
  """
  def online?(online_users, user_id) do
    Map.get(online_users, user_id, 0) > 0
  end

  @doc """
  Subscribe to the online users topic.

  ## Examples

      iex> subscribe()
      :ok
  """
  def subscribe() do
    Phoenix.PubSub.subscribe(Slax.PubSub, @topic)
  end

  def update(online_users, %{joins: joins, leaves: leaves}) do
    online_users
    |> process_updates(joins, &Kernel.+/2)
    |> process_updates(leaves, &Kernel.-/2)
  end

  defp process_updates(online_users, updates, operation) do
    Enum.reduce(updates, online_users, fn {id, %{metas: metas}}, acc ->
      Map.update(
        acc,
        String.to_integer(id),
        length(metas),
        &operation.(&1, length(metas))
      )
    end)
  end
end
